#!/usr/bin/env bash
# Stop — a PR opened without /ship's post-create step must not end silently.
#
# The PR gate hook rails /ship up to the create; the advisory review happens
# after it, and the session end is the only later chokepoint. Every
# open draft PR by this account updated in the last 24h must carry a
# `codex-advisory-review head=<sha>` (or claude-advisory-review) comment whose
# sha prefixes the PR's current head — a marker on an older head reviewed code
# that no longer exists — or a written "advisory review BLOCKED: <external
# precondition>" line in the body. A bare "deferred" does not satisfy it.
# Fail-open: no gh, no auth, no network, any parse failure exits 0. Fires once
# per session and violation set.

set -uo pipefail

payload="$(cat 2>/dev/null || true)"
session="$(jq -r '.session_id // empty' 2>/dev/null <<<"$payload" || true)"
[[ -z "$session" ]] && session="nosid"

command -v gh >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

# macOS ships no `timeout`; fall back to gtimeout (coreutils) or run bare —
# GH_* env timeouts keep a bare gh call from hanging a stop indefinitely.
_to() {
  if command -v timeout >/dev/null 2>&1; then timeout 20 "$@";
  elif command -v gtimeout >/dev/null 2>&1; then gtimeout 20 "$@";
  else GH_REQUEST_TIMEOUT=20s "$@"; fi
}

prs_json="$(_to gh pr list --author "@me" --state open --draft \
  --json number,title,updatedAt,body,headRefName,headRefOid --limit 15 2>/dev/null)" || exit 0
[[ -z "$prs_json" ]] && exit 0

# Concurrent-session scoping: from a worktree, only THIS session's
# branch is ours to choreograph — repo-wide scanning made every session stop on
# every other session's fresh drafts. The main checkout keeps the repo-wide
# sweep (single-session posture, and the last line of defense).
git_common="$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" || git_common=""
git_dir="$(git rev-parse --path-format=absolute --git-dir 2>/dev/null)" || git_dir=""
if [[ -n "$git_common" && -n "$git_dir" && "$git_dir" != "$git_common" ]]; then
  cur_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" || cur_branch=""
  if [[ -n "$cur_branch" && "$cur_branch" != "HEAD" ]]; then
    prs_json="$(jq --arg b "$cur_branch" '[.[] | select(.headRefName == $b)]' \
      <<<"$prs_json" 2>/dev/null)" || exit 0
    [[ -z "$prs_json" || "$prs_json" == "[]" ]] && exit 0
  fi
fi

cutoff="$(date -u -v-24H '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || date -u -d '24 hours ago' '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null)" || exit 0

violations=""
while IFS=$'\t' read -r num title head_oid; do
  [[ -z "$num" ]] && continue
  # A written BLOCKED note satisfies the step, but ONLY the anchored marker with a
  # non-empty precondition: "advisory review BLOCKED: <what it waits on>". This is
  # the only valid non-run outcome (there is no weekly audit to defer into). A bare
  # "deferred", a colon with nothing after it, or the word "blocked" floating
  # unrelated in the body does NOT satisfy it.
  body="$(jq -r --argjson n "$num" '.[] | select(.number==$n) | .body' <<<"$prs_json" 2>/dev/null)"
  if grep -qiE 'advisory review BLOCKED:[[:space:]]*[^[:space:]]' <<<"$body"; then
    continue
  fi
  comments="$(_to gh pr view "$num" --json comments \
    -q '.comments[].body' 2>/dev/null)" || exit 0
  # HEAD-BOUND marker check: pull every `head=<7-40 hex>` out of the comments and
  # accept only if the PR's CURRENT headRefOid starts with one of them. A marker
  # from an earlier push reviewed code that has since been replaced, and the old
  # substring match let it satisfy the step forever.
  matched=0
  while read -r sha; do
    [[ -z "$sha" ]] && continue
    if [[ -n "$head_oid" && "$head_oid" == "$sha"* ]]; then
      matched=1
      break
    fi
  done < <(grep -oE '(codex|claude)-advisory-review head=[0-9a-fA-F]{7,40}' <<<"$comments" \
    | sed -E 's/.*head=//' | tr '[:upper:]' '[:lower:]')
  if [[ $matched -eq 0 ]]; then
    violations+="  #${num} — ${title}"$'\n'
  fi
done < <(jq -r --arg c "$cutoff" \
  '.[] | select(.updatedAt > $c) | [(.number|tostring), .title, (.headRefOid // "")] | @tsv' \
  <<<"$prs_json" 2>/dev/null)

[[ -z "$violations" ]] && exit 0

vkey="$(printf '%s' "$violations" | shasum 2>/dev/null | cut -c1-12)"
marker="${TMPDIR:-/tmp}/.claude-ship-choreo-stop-$(id -u)-${vkey}-${session}"
[[ -f "$marker" ]] && exit 0
touch "$marker" 2>/dev/null || true

cat >&2 <<EOF
STOP CHECK — open draft PR(s) missing /ship step 6 (independent advisory review):
${violations}
Each needs ONE of:
  - the advisory review run + adjudicated: /ship step 6 (codex_review_pr.py, then
    the single adjudication comment headed `codex-advisory-review head=<current
    head sha>` — a marker naming an OLDER head does not count; re-review the
    head you just pushed), or
  - the review BLOCKED on a named external precondition, written into the PR
    body ("Codex advisory review BLOCKED: <what it's waiting on>"). There is no
    weekly audit to defer into — BLOCKED-on-something is the only non-run outcome.
An unwritten or unblocked skip is a skipped step, not a deferral. Resolve, or stop again
if these PRs are another session's in-flight work (this fires once per state).
EOF
exit 2
