---
name: diagnose
description: Instrument-first bug diagnosis — a symptom to a root cause through a reproducible feedback loop, never a guess. Use on "why is this happening", a flaky test, a cost or perf anomaly, drifting LLM output. Not for a known bug with an obvious fix.
---

# diagnose

Never theorise before you can reproduce. A guess dressed as an explanation gets committed as a fix that fixes nothing and buries the real cause.

## The six phases

**1. Build the feedback loop first.** A deterministic, fast, unattended signal that goes red on the bug:

| Symptom | Loop |
|---|---|
| Application logic | a failing test, run the way `scripts/gate.sh` runs it |
| Route or API behaviour | a `curl` script against the running service |
| CLI or workflow step | a minimal script and a small fixture |
| UI behaviour | a headless Playwright script against a local instance |
| Intermittent or timing | a trace replay or a bisection harness |
| Drifting LLM output | a fixture with the failure encoded, driven against a local instance. If no fixture expresses the failure yet, writing it is the first deliverable |
| Perf, CPU, cost | process stats, timing logs; never "expected workload" without a number |

If you cannot build one, "not reproducible" is the finding.

**2. Reproduce and minimise.** Confirm the loop catches the real failure, then strip inputs until only the load-bearing parts remain. What you had to keep is close to the cause.

**3. Hypothesise, ranked and falsifiable.** Three to five, each with a prediction: if X causes this, changing Y removes or worsens it.

**4. Instrument one variable per probe.** LLM output wrong: dump the raw result at the model call before blaming the model; the corruption is often a later step mutating it. Slowness: baseline, then bisect. A probe that neither confirms nor eliminates a hypothesis was badly designed.

**5. Regression test before the fix**, at the right seam. Red for the right reason, fix, green, then the original unminimised scenario end to end.

**6. Clean up and capture.** Strip the instrumentation. An architectural gap gets a paragraph on `PLAN.md`. The correct hypothesis goes in the commit message. A diagnosis over fifteen minutes, or a repeat, is deposited with `.claude/scripts/log-lesson.sh`.

## Rationalisations to reject

"I can see the bug reading the code" (an unfalsified theory). "Intermittent, can't reproduce" (a harder loop, not a licence to skip one). "Obvious fix, skip the test". "Probably the model being inconsistent" (dump the call first). "Feels slow" (measure).
