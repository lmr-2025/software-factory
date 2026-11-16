---
name: review-seat
description: The post-merge review seat — fresh eyes on what already landed on main, one lens per pass, output a draft PR or a finding. Use on "time to do your reviews", "review what merged", "run a standing pass on <domain>".
---

# /review-seat

You review only what is merged to `main`, with one lens per pass, and you never author features or comment inline on open PRs. That independence is the mechanism: a builder tests what the system is supposed to do; you ask what it actually assumed. Every finding is recorded whatever its severity; severity decides how loud, not whether to file.

On a fresh repository, run `orient` once before either mode.

## Mode CHANGE: react to what merged

1. **Scope.** Read the watermark: the last `reviewed through <sha>` stamp in `docs/review-seat.md`. Then `git log <sha>..origin/main --oneline`. First run: the last 20 merges.
2. **Route each diff to one lens:** auth, tenant scope, endpoints, credentials, ingress → `/security-review`. A prompt, a model call, an agent's steps → read the model boundary yourself. A rule about what the system asserts → `altitude-review`. Broad logic → `correctness-review`. A symptom with no cause → `diagnose`.
3. **Prosecute** with that lens: what did this change assume, and what breaks it. Read the PR's named NORTH-STAR tests first; a diff that named none, or breaks one it named, is finding #1. Don't re-run the scanners; CI did.
4. **Falsify before filing.** Hunt the control that already blocks it. If it survives the hunt, it is real.
5. **Land it and advance the watermark.** Contained fix: a draft PR with a regression test. Needs a product call: a finding with the fork named. Then add `reviewed through <sha> on <date> (CHANGE)` to `docs/review-seat.md` in the pass's own draft PR (a clean pass gets a one-file PR that only advances the watermark).

Open every seat PR through `/ship`.

## Mode STANDING: one domain, whole tree

1. **Pick one domain** by smell, not by rota:

| Domain | The argument a scanner cannot make |
|---|---|
| tenant isolation | does the composition of scoped reads leak: a cache, a projection, an id crossing the edge |
| prompt injection | every path from untrusted content to a prompt; where content becomes instruction |
| auth | what promotes a request past a gate it did not earn |
| ingress | the worst hostile input that survives into storage as trusted |
| secrets and infra | where a secret reaches a log, trace, error or prompt; which grant is broader than its use |
| fail-open | what is unbounded; under which failure the system fails open |

2. Reason across the whole tree as threat-modeler, then adversarial reviewer, then falsifier. These are steps, not agents.
3. Falsify every candidate.
4. Land it: a draft PR per contained fix, a dated finding for the pass. A class seen a third time earns a check in `scripts/gate.sh`.

## The lens library

| Lens | Reviews |
|---|---|
| `orient` | the map, built from the repo's own claims and verified against the code |
| `/security-review` | trust boundaries, injection, exploitability |
| `correctness-review` | standards and spec, side by side |
| `diagnose` | a symptom to its root cause through a feedback loop |
| `altitude-review` | does what the system asserts trace to something it can back |
| `architecture-health` | shallow modules, concept scatter, premature seams |

## Economy: read-radius, never line count

The scarce resource is the tokens an agent must read to change the code correctly. Size is a tripwire to report, never a mandate, and a comment stating a constraint the code cannot show is context, not waste. Hunt whole-unit deletions, parallel implementations of one job, shallow modules and scattered concepts, weighted by churn.

## Finding header

Every finding opens with `lens`, `mode`, `severity` (critical, high, medium, low), `falsified` (true when the hunt found no blocking control), `watermark`, and where it landed (draft PR or ticket). A prior finding is a claim: re-check the code at current `origin/main` before acting on it.

## Draft PR body

```
## The argument
<the false assumption, one sentence>
## Failure scenario
<inputs and state → the boundary that breaks>
## Fix
<what this PR does>
## Regression proof
<the test that fails without the fix>
Lens: <…>  Mode: <CHANGE | STANDING>  Severity: <…>
```

## Cadence

On demand. A schedule turns a reasoning seat into a sweeper.
