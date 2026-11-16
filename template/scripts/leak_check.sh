#!/usr/bin/env bash
# Leak check: no internal name, link or path reaches the tree.
#
# Reads patterns (one extended regex per line, case-insensitive; blank lines
# and lines starting with # are skipped) from two places:
#   - .leak-patterns          committed: generic shapes that never belong in
#                             this repo (session links, private paths)
#   - .leak-denylist          NOT committed (it is in .gitignore): the names
#                             of your clients, partners, people and private
#                             repos. A denylist of client names is itself a
#                             leak, so it lives only on your machine.
# Scans every tracked file plus anything staged. Any hit is a red gate.
#
# Usage: scripts/leak_check.sh [paths...]   (default: the whole tree)
set -uo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

patterns="$(cat .leak-patterns .leak-denylist 2>/dev/null | grep -vE '^[[:space:]]*(#|$)' || true)"
if [ -z "$patterns" ]; then
  echo "leak_check: no patterns found (.leak-patterns, .leak-denylist); nothing to check"
  exit 0
fi
[ -f .leak-denylist ] || echo "leak_check: no .leak-denylist on this machine; checking generic patterns only"

if [ $# -gt 0 ]; then
  files=("$@")
else
  mapfile -t files < <(git ls-files --cached --others --exclude-standard)
fi

# These two files hold the patterns themselves.
skip='^(\.leak-patterns|\.leak-denylist)$'
hits=0
for f in "${files[@]}"; do
  [[ "$f" =~ $skip ]] && continue
  { [ -r "$f" ] && [ ! -d "$f" ]; } || continue
  out="$(grep -nIiE -f <(printf '%s\n' "$patterns") -- "$f" 2>/dev/null || true)"
  if [ -n "$out" ]; then
    printf '%s\n' "$out" | sed "s|^|$f:|"
    hits=$((hits + 1))
  fi
done

if [ "$hits" -gt 0 ]; then
  echo "leak_check: RED, $hits file(s) carry a denied pattern (above)"
  exit 1
fi
echo "leak_check: clean (${#files[@]} files)"
