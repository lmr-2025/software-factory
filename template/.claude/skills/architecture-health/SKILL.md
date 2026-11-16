---
name: architecture-health
description: The review seat's standing lens for structural rot — shallow modules, concept scatter, seams formalised before variation existed — prioritised by churn. Use on "is this module too shallow", in a periodic standing pass, or before a piece of work opens (pre-build mode: what deepening makes this change easy). Output is a deepening proposal as a finding, a draft PR only when the refactor is small and test-covered.
---

# architecture-health

Find where structure rotted merge by merge while every diff looked fine, and say what deepening would pay for itself. A reasoning pass over design, not a smell scan (`correctness-review` carries the smell baseline). Low frequency: architecture drifts over months.

## Vocabulary

- **Module:** anything with an inside and an outside.
- **Interface:** everything a caller must know to use it correctly, including ordering, error contracts and state assumptions, documented or not.
- **Depth:** behaviour hidden per interface exposed. Shallow means the interface is nearly as complex as the implementation.
- **Seam:** a boundary where behaviour varies. One adapter is hypothetical; two are real. Do not formalise a seam before the variation exists.
- **Leverage:** what callers get from depth.
- **Locality:** what maintainers get from depth: a change, its bugs and its verification land in one place.
- **The interface is the test surface.** Callers and tests cross the same seam; a test that has to reach past it (a private import, a patched internal) says the module is the wrong shape.

## The pass

**Pre-build mode** (a piece of work about to open; `/brainstorm` step 1 runs it): skip steps 0 and 1, run 2 to 6 on the modules the paragraph will touch, and ask *what deepening would make this change easy?* A candidate that makes the work cheap becomes its first PR rather than a finding.

0. **Pick the area by churn.** Rank top-level directories by `git log --since=<last pass> --name-only` volume and take the stalest churning one.
1. **Within the area, prioritise by churn:** `git log --since='3 months' --format= --name-only -- <paths> | sort | uniq -c | sort -rn`. A shallow module nobody touches is not worth a proposal.
2. **Measure depth.** Read the interface first, then the implementation. Could fewer methods, simpler parameters, or a returned value instead of a side effect hide more? Count the tests that reach past the interface; a cluster is the evidence.
3. **Hunt concept scatter.** One idea spread across N files, so every change is shotgun surgery. The grep trail from a recent real change is the evidence.
4. **Deletion test.** Imagine the module deleted and its logic pushed to callers. Complexity concentrates in the callers: keep and deepen. Complexity merely moves: fold it away.
5. **Classify what sits behind the seam; it decides the test plan.** In-process: merge and test through the new interface. A local stand-in exists (a temp git repo, a local database): test with it, no port. Yours but remote: a port with an in-memory adapter for fast tests, plus at least one test through the real transport. Truly external (a model provider, GitHub): an injected port and a mock adapter. Name the tests the new interface's tests replace; they are deleted, not kept alongside.
6. **Falsify.** Hunt the reason the shape is deliberate: a recorded decision, a performance constraint, a second adapter about to land, a deepening a prior pass proposed and the owner rejected. A documented reason is not drift; when the friction is real enough to reopen it, say *contradicts <where>, reopen because <evidence>*.

## Output

- Default: a deepening proposal as a finding: the module, its current interface cost with file:line from real call sites, the proposed interface (invariants and error modes), what concentrates where, the dependency category and the tests it replaces, the migration seam.
- A draft PR only when the refactor is small, mechanical, behaviour-preserving and fully test-covered.
- A proposal rejected for a reason a future pass would need is marked *rejected: <reason>* so nothing re-proposes it.

Method after John Ousterhout, *A Philosophy of Software Design*. The test-surface and dependency-category ideas are adapted from Matt Pocock's skills (github.com/mattpocock/skills, MIT), rewritten here.
