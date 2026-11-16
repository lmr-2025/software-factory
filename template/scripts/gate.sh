#!/usr/bin/env bash
# The local gate is CI, verbatim.
#
# A draft PR gets no CI (the `if:` on the jobs in ci.yml): the draft's evidence
# is this gate, and CI runs at the ready flip. So every gap between this file
# and ci.yml lands on whoever flips. This file does not paraphrase the
# workflow: the `run:` lines of the `gate` job are here in their order, plus
# the secret scan. When you add a step to one, add it to the other in the same
# PR. (A test that diffs the two keeps them honest once the repo is big enough
# to forget.)
#
# Usage:  scripts/gate.sh [--out <dir>]
#   Builds a fresh venv under <out>/venv every run, because CI's is fresh.
#   Logs every step to <out>/gate.log. <out> defaults to .gate/ (gitignored).
#   The last line of the log is the verdict; read it, not a pipe's exit code.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
OUT="$ROOT/.gate"
while [ $# -gt 0 ]; do
  case "$1" in
    --out) OUT=$2; shift 2 ;;
    *) echo "usage: scripts/gate.sh [--out <dir>]" >&2; exit 2 ;;
  esac
done
mkdir -p "$OUT"
LOG="$OUT/gate.log"
: > "$LOG"
step() { printf '\n=== %s ===\n' "$1" | tee -a "$LOG"; }
run() { "$@" 2>&1 | tee -a "$LOG"; return "${PIPESTATUS[0]}"; }

# Match CI's interpreter; an older system python3 fails on newer syntax.
PY="${PYTHON:-}"
for c in python3.12 python3.13 python3; do
  if [ -z "$PY" ] && command -v "$c" >/dev/null 2>&1; then PY="$c"; fi
done
VENV="$OUT/venv"
rm -rf "$VENV"
step "fresh venv ($PY)"
run "$PY" -m venv "$VENV"
# shellcheck disable=SC1091
source "$VENV/bin/activate"
run python --version

# ---- The steps below mirror the `gate` job in .github/workflows/ci.yml ------
# Replace them with this repository's own. Prefer installing from a
# hash-pinned requirements file (pip install --require-hashes -r ...).

step "Install tooling"
run python -m pip install --quiet --upgrade pip pytest ruff

step "Lint"
run ruff check .

step "Tests"
run pytest -q

step "Leak check"
run scripts/leak_check.sh

# ---- Secret scan -------------------------------------------------------------
step "Secret scan"
if command -v gitleaks >/dev/null 2>&1; then
  run gitleaks git --no-banner --redact --config .gitleaks.toml .
else
  # A draft gets no CI, so this gate is the draft's only secret scan: a
  # missing scanner is a red gate, not a note.
  echo "RED: gitleaks is not installed and this gate is the draft's only secret scan. Install it, then rerun." | tee -a "$LOG"
  exit 1
fi

step "All checks passed"
