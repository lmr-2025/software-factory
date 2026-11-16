# Log

One dated line per merged PR, newest first, written in the same commit as the work. A line says what landed, which NORTH-STAR test it moved, and what it left for the next session. The spec is never here; it is the paragraph on `PLAN.md`.

- 2026-01-15 — **One-command install** (NORTH-STAR test 1) — `scripts/install.sh` sets up a clean machine in one step and refuses to overwrite an existing config. Left: Windows is untested.
