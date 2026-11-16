---
name: promote-lessons
description: Cold promotion pass over the lesson log — cluster rows, count repeats across sessions, route each recurring pattern to the rail that fires where the mistake happens. Use in a fresh session on "promote the lessons" or when the log has 8 or more unpromoted rows.
---

# /promote-lessons

Run cold: in a session not loaded with the framing of the session that hit the lesson. A session opened for this pass is cold enough. Every recurring lesson earns a mechanical rail, a skill that loads at the point of use, or a written reason it cannot be mechanised. "Remembered by Claude" is not a category.

## Inputs

`~/.claude/projects/<sanitized-main-checkout-path>/lessons.log` (written by `.claude/scripts/log-lesson.sh`), TSV rows `ts, session-id, class, lesson, seam`. The active window is every row below the trailing `# promoted-through: <ISO8601>` marker, whatever its date: a singleton logged before the marker but never promoted is still live.

Empty window: say so and stop.

## Procedure

1. **Gather** the active window.
2. **Audit the self-graded stops.** Sessions invent owner gates. The closed list of real gates: the ready flip on a rules change, a production or cloud change, spend past authority, a product-model or taste fork, a freeze after the owner interrupts. Look back at a handful of recent stops that claimed an owner gate; a claimed gate outside that list, or a decidable fork held instead of decided, is a false gate. Log it as a `false-owner-gate` row so it clusters like any other pattern.
3. **Cluster** rows into patterns by class and lesson text.
4. **Count distinct sessions** per cluster, with the dated rows as evidence. One session logging the same thing twice is N=1.
5. **Route by what fires the mistake:**
   - N=1: keep it below the marker; do not promote. It stays live so a later repeat can join it.
   - N≥2 with a deterministic signal (a shell pattern, a missing marker, a forbidden import): a check wired into `scripts/gate.sh`, its dated rows in the docstring. A check nothing runs is not a rail.
   - N≥2, triggered while editing a kind of file: a line in the skill that owns that kind of file.
   - N≥2, triggered while running something: a PreToolUse hook first, else the skill that owns that action, else CLAUDE.md only if it shapes every turn.
   - Memory is the last resort, and still goes through review: stage the proposed memory as a note in the draft PR for the owner to install. Never write the live memory directory from this pass.
   - N≥3: same routing, flagged loudly in the report.
6. **Author everything through one draft PR** from a worktree. No ready flip. Nothing at N≥2 means no PR, just the report.
7. **Guard the always-loaded budget.** Target zero additions to CLAUDE.md, and state the count.
8. **Settle the log.** Rows that graduated move above the marker; every other row stays below. A singleton with no repeat in 90 days may be buried above the marker with a `# buried-stale:` note, stated in the report. Set `# promoted-through:` to now (UTC).
9. **Emit one report:** per cluster the pattern, N with dates, the fate and the PR link; then the budget line and the new marker.

Never flip or merge, never loosen an existing gate check, never wire the log into anything that loads every turn.
