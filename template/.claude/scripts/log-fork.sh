#!/usr/bin/env bash
# Append one judgment-free fork row to ~/.claude/projects/<repo>/forks.log.
#
# A fork is a moment the session was unsure which way to go. Logging every one,
# and how it resolved, shows over time which forks the canon should have
# settled (dissolved ones), which still need better context (open ones), and
# what the owner's taste looks like (the ones the owner flipped). Deposit only;
# never fails its caller. Same shared-log pattern as log-lesson.sh.
#
# Usage: log-fork.sh <state> <grade-or-dash> "<fork one-liner>" ["<resolution>"]
#   state       OPEN | DECIDED | DISSOLVED
#   grade       explicit | confirmed | silent-assent | never-surfaced
#               (DECIDED only; "-" otherwise)
#   fork        one line: what was unsure
#   resolution  optional: what resolved it and what was picked
set -u

state="${1:-}"
grade="${2:-}"
fork="${3:-}"
resolution="${4:-}"

case "$state" in
  OPEN|DECIDED|DISSOLVED) ;;
  *)
    echo "log-fork: invalid state '$state' (want OPEN|DECIDED|DISSOLVED); skipped." >&2
    exit 0
    ;;
esac

if [ -z "$fork" ]; then
  echo "log-fork: need a <fork one-liner>; skipped." >&2
  exit 0
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd 2>/dev/null || true)"
common_git="$(git -C "$script_dir" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)"
main_checkout="${common_git%/.git}"
if [ -z "$main_checkout" ]; then
  main_checkout="$(cd "$script_dir/../.." && pwd 2>/dev/null || true)"
  [ -z "$main_checkout" ] && main_checkout="$(pwd)"
fi
sanitized="$(printf '%s' "$main_checkout" | tr '/' '-')"
log="$HOME/.claude/projects/${sanitized}/forks.log"
mkdir -p "$(dirname "$log")" 2>/dev/null || true

if [ ! -f "$log" ]; then
  {
    printf '# Fork log. Deposit-only, judgment-free.\n'
    printf '# Dissolved forks show what the canon should have settled; open forks\n'
    printf '# show where context is thin; owner-flipped forks are the taste record.\n'
    printf '# Kept to understand, not fed into /promote-lessons.\n'
    printf '# promoted-through: 1970-01-01T00:00:00Z\n'
  } >> "$log" 2>/dev/null || true
fi

sanitize() { printf '%s' "$1" | tr '\t\n\r' '   '; }

ts="$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo unknown)"
sid="${CLAUDE_CODE_SESSION_ID:-${CLAUDE_SESSION_ID:-unknown}}"

grade_out="-"
if [ "$state" = "DECIDED" ]; then
  case "$grade" in
    explicit|confirmed|silent-assent|never-surfaced) grade_out="$grade" ;;
    *) grade_out="$(sanitize "${grade:-}")" ;;
  esac
fi

printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
  "$ts" "$sid" "$state" "$grade_out" "$(sanitize "$fork")" "$(sanitize "$resolution")" \
  >> "$log" 2>/dev/null \
  || { echo "log-fork: could not write $log; skipped." >&2; exit 0; }

exit 0
