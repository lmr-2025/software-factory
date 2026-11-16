---
name: correctness-review
description: The review seat's correctness lens — two independent axes, STANDARDS (repo conventions plus a Fowler smell baseline, skipping what the gate enforces) and SPEC (the paragraph on PLAN.md), reported side by side and never merged. Use when the review seat routes a diff here or on "review this merge against its spec".
---

# correctness-review

Code can pass standards while dropping a requirement, or match the spec badly. Run both axes and report them side by side; never rank one against the other.

## Setup

1. **The diff:** `git show <merge-sha>`, or the range since the watermark.
2. **The spec:** the paragraph on `PLAN.md` the PR built against (the title's *makes runnable* and the ticket name it), including Log lines that amended it. No paragraph found: say the SPEC axis has nothing to check against, rather than inventing one.

## Running both axes

Two subagents in parallel, one per axis, each given only the diff and its own source material, so one axis's read does not colour the other. A small diff can run both yourself in strict order, with the STANDARDS findings written down before the spec is opened.

**STANDARDS**, in order:
1. Documented conventions first, and they override the baseline: CLAUDE.md's hard rules, NORTH-STAR's tests, the paragraph.
2. Skip anything `scripts/gate.sh` enforces; read the gate if unsure. An issue the gate should catch but is still present is a gate gap; file that.
3. **A kept path names its caller.** A mode, flag, default, wrapper, alias or fallback the diff adds or keeps "for compatibility" names a current caller at file:line, or it is deleted in the same PR. Callers a symbol grep misses count (a string dispatch, a runbook command, data on disk in an older shape). A path whose only callers are its own tests has none.
4. Fowler smells scoped to the diff: mysterious name, duplicated code, feature envy, data clumps, primitive obsession, repeated switches, shotgun surgery, divergent change, speculative generality, message chains, middle man, refused bequest.

**SPEC**, walking the diff against the paragraph line by line:
- Missing or partial: a stated requirement not implemented (quote the line).
- Scope creep: the diff does what the paragraph never asked; unreviewed surface is a finding.
- Incorrect: the behaviour diverges from the line (quote both).

Every SPEC finding quotes its spec line, or it is dropped.

## Falsify before filing

Per finding: a check that already catches it, a spec line you missed that permits it, a later commit in the same merge that fixes it.

## Report

```
## STANDARDS
- <finding> — <convention or smell> (file:line)   | none found (checked <docs>; gate checks skipped: <list>)
## SPEC
Source: <paragraph heading>
- <finding> — "<spec line>" vs <what the diff does> (file:line)   | none found
```

A contained fix on either axis: a draft PR with a regression test. A SPEC gap needing a product call, or a STANDARDS class that should be a gate check: a finding.
