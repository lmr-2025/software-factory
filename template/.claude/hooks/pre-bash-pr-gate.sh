#!/usr/bin/env bash
# PreToolUse(Bash) — `gh pr create` arrives through /ship, as a draft.
#
# A bare create is blocked; `--draft` passes; `# --ready-confirmed` is a
# trailing shell comment a session appends only after the owner chose to open
# it ready. Both are read from a quote- and heredoc-stripped view of the
# command, never from a title or body. The create must also be the tail of a
# ship run: /ship touches `.claude-ship-run` at the git toplevel after the gate
# is green and the record line is committed. This hook wants a marker under
# 6 hours old and consumes it on pass. Block messages say "run /ship" and name
# no bypass.

set -uo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/_common.sh"

read_payload
cmd="$(field '.tool_input.command')"
[[ -z "$cmd" ]] && exit 0

# Two views of the command, both with quoted strings and heredoc bodies
# removed, because `--draft` and `# --ready-confirmed` must never be read out
# of prose: a `--title "x --draft"` would otherwise pass the draft gate, and a
# PR body mentioning `--ready-confirmed` would self-grant the ready path.
#   stripped — comments also removed: the subcommand and `--draft` match here.
#   comments — trailing comments kept: the only place `# --ready-confirmed`
#              is honored.
_awk_strip='
  BEGIN { in_heredoc = 0 }
  {
    line = $0
    if (in_heredoc) { if (line == delim) in_heredoc = 0; next }
    if (match(line, /<<-?[[:space:]]*['"'"'"]?[A-Za-z_][A-Za-z0-9_]*['"'"'"]?/)) {
      d = substr(line, RSTART, RLENGTH)
      sub(/<<-?[[:space:]]*/, "", d); gsub(/['"'"'"]/, "", d)
      delim = d; in_heredoc = 1
    }
    gsub(/"[^"]*"/, "\"\"", line)
    gsub(/'"'"'[^'"'"']*'"'"'/, "", line)
'
stripped="$(printf '%s' "$cmd" | awk "${_awk_strip}"'
    sub(/[[:space:]]#.*$/, "", line)
    print line
  }')"
comments="$(printf '%s' "$cmd" | awk "${_awk_strip}"'
    if (match(line, /[[:space:]]#/)) print substr(line, RSTART)
  }')"
printf '%s' "$stripped" | grep -Eq -- '(^|[;&|[:space:]])gh([[:space:]]+--?[^[:space:]]+)*[[:space:]]+pr[[:space:]]+create([[:space:]]|$)' || exit 0

if ! printf '%s' "$stripped" | grep -Eq -- '(^|[[:space:]])--draft([[:space:]=]|$)' \
  && ! printf '%s' "$comments" | grep -Eq -- '#[[:space:]]*--ready-confirmed'; then
  block "Blocked: 'gh pr create' without --draft. A session opens a DRAFT PR; it flips to ready only after the gate is green and the advisory review is adjudicated. Run /ship; it opens the draft as its own step."
fi

top="$(git -C "${HOOK_CWD:-.}" rev-parse --show-toplevel 2>/dev/null || true)"
[[ -z "$top" ]] && block "Blocked: 'gh pr create' from outside a git repository, so the ship run cannot be verified. Run /ship from the worktree holding the work."

marker="$top/.claude-ship-run"
if [[ ! -f "$marker" ]] || [[ -z "$(find "$marker" -mmin -360 2>/dev/null)" ]]; then
  block "Blocked: 'gh pr create' without a fresh ship run. Opening the PR is the ship moment, and the steps before it (the gate green, the record line in the same commit, the three fields in the PR title) only happen there. Run /ship. Subagent builders: end at commit and push and report; the orchestrating session ships."
fi

rm -f "$marker" 2>/dev/null || true
exit 0
