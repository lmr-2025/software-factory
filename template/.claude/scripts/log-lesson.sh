#!/usr/bin/env bash
# Append one judgment-free lesson row to ~/.claude/projects/<repo>/lessons.log.
#
# Deposit only: no promotion judgment happens here. If in doubt, log it; a
# junk row is one line the cold /promote-lessons pass drops. This script must
# never fail its caller, so every error path still exits 0.
#
# Usage: log-lesson.sh "<class>" "<lesson>" ["<seam file:line>"]
#   class   coarse kebab tag (shell-mutation, stale-state-claim, ...), free text
#   lesson  one line: what happened and the corrective (a do-this, not a don't)
#   seam    optional file:line or seam name
#
# The log sits on disk unread. Nothing loads it into a working session; only
# /promote-lessons reads it.
set -u

class="${1:-}"
lesson="${2:-}"
seam="${3:-}"

if [ -z "$class" ] || [ -z "$lesson" ]; then
  echo "log-lesson: need <class> and <lesson>; skipped." >&2
  exit 0
fi

# One shared log per repository, outside every checkout, so no worktree ever
# carries it as a dirty tracked file. The directory name follows Claude Code's
# own ~/.claude/projects/<dir> naming (each "/" in the main checkout's absolute
# path becomes "-"). git's common dir finds the main checkout from a worktree.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd 2>/dev/null || true)"
common_git="$(git -C "$script_dir" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)"
main_checkout="${common_git%/.git}"
if [ -z "$main_checkout" ]; then
  main_checkout="$(cd "$script_dir/../.." && pwd 2>/dev/null || true)"
  [ -z "$main_checkout" ] && main_checkout="$(pwd)"
fi
sanitized="$(printf '%s' "$main_checkout" | tr '/' '-')"
log="$HOME/.claude/projects/${sanitized}/lessons.log"
mkdir -p "$(dirname "$log")" 2>/dev/null || true

# Seed the header and the active-window marker on a fresh log. The promoter
# reads only rows below the last `# promoted-through:` marker, so a log with no
# marker would have no window. Dated 1970 so it never masks a real row.
if [ ! -f "$log" ]; then
  {
    printf '# Lesson candidate log. Sits on disk unread.\n'
    printf '# Deposit-only; the cold /promote-lessons pass is the only reader.\n'
    printf '# Rows below the marker are the live (un-promoted) window; the\n'
    printf '# promoter moves graduated rows above it.\n'
    printf '# promoted-through: 1970-01-01T00:00:00Z\n'
  } >> "$log" 2>/dev/null || true
fi

# One lesson is exactly one TSV row.
sanitize() { printf '%s' "$1" | tr '\t\n\r' '   '; }

ts="$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo unknown)"
# The session id matters: the promoter counts DISTINCT sessions, so a missing
# id would collapse every repeat to one.
sid="${CLAUDE_CODE_SESSION_ID:-${CLAUDE_SESSION_ID:-unknown}}"

printf '%s\t%s\t%s\t%s\t%s\n' \
  "$ts" "$sid" "$(sanitize "$class")" "$(sanitize "$lesson")" "$(sanitize "$seam")" \
  >> "$log" 2>/dev/null \
  || { echo "log-lesson: could not write $log; skipped." >&2; exit 0; }

exit 0
