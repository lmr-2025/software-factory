#!/usr/bin/env bash
# PreToolUse(Bash) — all authoring happens in worktrees.
#
# The shared main checkout stays on origin/main; when several sessions run at
# once, a commit there lands on whatever branch another session left HEAD on.
# Branch-creating and committing git commands are blocked when the target repo
# is this project's main checkout. Worktrees, reads, fetches and other repos
# pass. Killing processes by name is blocked too, because on a shared machine a
# name matches every session's processes.

set -uo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/_common.sh"

read_payload
cmd="$(field '.tool_input.command')"
[[ -z "$cmd" ]] && exit 0   # nothing to inspect; other hooks own their gates

# Heredoc bodies, comments and quoted strings are text, not commands: commit
# messages routinely contain the words "git commit".
noheredoc="$(printf '%s' "$cmd" | awk '
  BEGIN { in_heredoc = 0 }
  {
    line = $0
    if (in_heredoc) { if (line == delim) in_heredoc = 0; next }
    if (match(line, /<<-?[[:space:]]*['\''"]?[A-Za-z_][A-Za-z0-9_]*['\''"]?/)) {
      d = substr(line, RSTART, RLENGTH)
      gsub(/^<<-?[[:space:]]*/, "", d); gsub(/['\''"]/, "", d)
      delim = d; in_heredoc = 1
      sub(/<<-?[[:space:]]*['\''"]?[A-Za-z_][A-Za-z0-9_]*['\''"]?.*$/, "", line)
    }
    print line
  }
')"
stripped="$(printf '%s' "$noheredoc" | sed -E "s/'[^']*'/''/g; s/\"[^\"]*\"/\"\"/g; s/#.*$//")"

# ---- 1. No kill by name on a shared machine ---------------------------------
# A pattern meant for this session's test run also matches other sessions'
# runs, and a name can miss the children it meant to stop. Only
# `pkill -P <pid>` passes.
kills="$(printf '%s' "$stripped" | grep -oE -- '(^|[;&|({])[[:space:]]*((sudo|nohup|xargs|exec|command|then|do|else)[[:space:]]+)*([^[:space:];&|(){}]*/)?(pkill|killall)([[:space:]][^;&|)]*)?')"
if [[ -n "$kills" ]] && printf '%s\n' "$kills" | grep -Evq -- 'pkill[[:space:]]+-P[[:space:]]+[0-9]+[[:space:]]*$'; then
  block "BLOCKED: pkill/killall by name. On a shared machine the pattern matches other sessions' processes too.
Kill by the exact pid you hold, or stop your own process group:
  kill -- -\$(ps -o pgid= -p <that pid>)"
fi

# ---- 2. Is this a commit, branch-create or branch-switch? -------------------
# `git` in command position, optional global flags, then the gated subcommand.
git_prefix='(^|[;&|(){}[:space:]]|&&|\|\|)git([[:space:]]+(-[Cc][[:space:]]+[^[:space:]]+|--[a-z-]+(=[^[:space:]]+)?|-[a-z]))*[[:space:]]+'
gated=""
if printf '%s' "$stripped" | grep -Eq -- "${git_prefix}commit([[:space:]]|$)"; then
  gated="git commit"
elif printf '%s' "$stripped" | grep -Eq -- "${git_prefix}checkout[[:space:]]+(.*[[:space:]])?-[bB]([[:space:]]|$)"; then
  gated="git checkout -b"
elif printf '%s' "$stripped" | grep -Eq -- "${git_prefix}switch[[:space:]]+(.*[[:space:]])?(-[cC]|--create|--force-create)([[:space:]]|$)"; then
  gated="git switch -c"
fi
[[ -z "$gated" ]] && exit 0

# ---- 3. Is the target repo the shared main checkout? ------------------------
# `git -C <path>` decides the target repo; failing that, a leading
# `cd <path> &&` does. Commands routinely arrive as `cd /path && git commit`,
# and judging those against the session cwd lets the wrong one through.
unquoted="$(printf '%s' "$noheredoc" | tr -d "\"'")"
lead_cd="$(printf '%s' "$unquoted" | sed -nE 's/^[[:space:]]*cd[[:space:]]+([^;&|[:space:]]+)[[:space:]]*&&.*/\1/p' | head -1)"
target_dir="$(printf '%s' "$stripped" | sed -nE 's/.*git[[:space:]]+-[Cc][[:space:]]+([^[:space:]]+).*/\1/p' | head -1)"
[[ -z "$target_dir" ]] && target_dir="$lead_cd"
repo="$(git -C "${target_dir:-${HOOK_CWD:-.}}" rev-parse --show-toplevel 2>/dev/null || true)"
[[ -z "$repo" ]] && exit 0   # not in a git repo; git itself will error

# The main checkout of the project that owns THIS hook file. git-common-dir
# always points at the main checkout's .git, from a worktree too.
hook_repo="$(cd "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
main_gitdir="$(git -C "$hook_repo" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)"
[[ -z "$main_gitdir" ]] && exit 0
main_checkout="$(dirname -- "$main_gitdir")"

# Only the main checkout itself is gated. A linked worktree's toplevel differs.
[[ "$repo" != "$main_checkout" ]] && exit 0

block "BLOCKED: '$gated' on the SHARED main checkout ($main_checkout).
Concurrent sessions share it, so a commit here lands on whatever branch another
session left HEAD on. Author in a worktree instead:
  git -C $main_checkout fetch origin main
  git -C $main_checkout worktree add ../wt-<name> -b <branch> origin/main
Then run your git commands from that worktree. (CLAUDE.md § Working style)"
