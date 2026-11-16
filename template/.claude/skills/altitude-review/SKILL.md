---
name: altitude-review
description: The review seat's product-altitude lens — does something the system now asserts trace back to what it can actually back, and is a "synthesis" synthesising or just restating. Use on a diff that changes what the system tells users: a derivation rule, a summary or report, a new LLM behaviour.
---

# altitude-review

A product's promises (NORTH-STAR's tests) are properties of what the system *asserts*, not of how the code runs. A scanner cannot check them and a correctness reviewer waves them through. The tell: a dedup pass finds nothing, but the output still feels loose. The looseness is usually a decision that reached only half its consumers. Find the decision.

Write your own invariants into this table from NORTH-STAR. Typical ones:

| Invariant | The argument |
|---|---|
| Every claim traces to a source | Trace each assertion in the output back to its source. A claim with no trace is the core violation. |
| Synthesis, not restatement | Is the output combining facts into a higher claim, or echoing them with new formatting? |
| No black boxes | Every score or derivation can be followed to its inputs, and every prompt is readable. |
| No cross-customer aggregation | Any new read, cache or benchmark across customers is a hard no. |

## The pass

1. Scope the change to the invariant it most plausibly touches.
2. Prosecute that one: trace the assertion to its backing, or the read to its scope. Read the produced output; run the workflow on synthetic data if the drift only shows in output.
3. Falsify: hunt the mechanism that already keeps it honest.
4. Land it. A contained fix (a prompt that now cites, a query that now scopes): a draft PR. A half-propagated decision: a finding naming the decision and the consumers it did not reach, or a canon PR if the canon is ambiguous. A product-model fork (should this output make this claim at all): a finding with the fork named, never decided in review.

The authority is CLAUDE.md's hard rules and NORTH-STAR. This lens checks code against them; it never redefines them.
