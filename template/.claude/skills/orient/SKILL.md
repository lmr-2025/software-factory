---
name: orient
description: The review seat's grounding lens — build the map from the repo's own artifacts and verify every claim against the code; canon-says-X-but-code-does-Y is finding #1. FULL once per unfamiliar codebase; SCOPED is the standing check that the docs still match the code, one slice at a time.
---

# orient

A fresh-eyes reviewer needs a map, and a map someone hands you leads the witness. Build the map from the code and treat the canon (NORTH-STAR, PLAN.md, CLAUDE.md, recorded decisions) as claims to verify. Where the canon says X and the code does Y, that gap is finding #1, filed like any other, never reconciled in your head.

## FULL: build your map

1. **Primary sources only.** Read the code and the doc that owns each concept, never a paraphrase. Follow the trail: a NORTH-STAR test, to a paragraph, to the code that implements it. A dead-end trail is a note.
2. **Challenge the terminology.** When a word does double duty, pin which meaning is live in the code you are reading.
3. **Stress-test with concrete scenarios.** A user uploads a file saying "ignore prior instructions"; two scoped queries are joined; a record marked approved whose evidence expired. The scenario the canon cannot answer cleanly is where the review starts.
4. **Cross-check every claim you will rely on.** Backed: firm. Contradicted: finding #1. Unbacked: a note.
5. **Stop when grounded**: when you can name the trust boundaries, the main nouns, and where canon and code disagree.

Output is a map held in the session, or a dated finding if enough drift surfaced.

## SCOPED: do the docs still match the code?

1. Pick one slice: one doc, one paragraph, one runbook. Note it in the stamp so the next pass picks the least recently checked.
2. Extract every falsifiable claim: named files and flags exist, cited checks run in `scripts/gate.sh` or CI, links resolve, described behaviour matches the code at file:line, a Done-means the docs call met is met.
3. Verify against `origin/main` (`git show origin/main:<path>`), never the local tree.
4. Route: a stale pointer or dead link is fixed in the pass's draft PR. A doc that is wrong because the decision changed under it is a finding with the fork named. True but unenforced is a gate-check candidate.
5. Verify that docs match code; never opine on how the docs are organised.
