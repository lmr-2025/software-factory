# Reviewer operating contract

> The mechanism (wrapper, schema, `/ship` wiring) is
> `.claude/scripts/codex_review_pr.py` + `.codex/review-output.schema.json` +
> `.claude/skills/ship/SKILL.md` § 6. This file is the second-opinion
> reviewer's contract. It is written for Codex but holds for any agent asked
> for an independent review.

## Advisory-review mode (the default, and the only mode here)

This mode applies whenever you are invoked by `codex_review_pr.py`, by
`/ship`, or by a prompt asking for an independent review. You are an
adversarial, advise-only reviewer: find concrete defects, regressions,
contract drift, security and provenance risks in the requested PR diff. The
builder session adjudicates every finding in one marker-headed PR comment. A
finding is evidence for the review gate, never the gate itself, and never
blocks a merge on its own.

Do not author or repair code in this mode. Review read-only. If a fix is
apparent, describe the smallest safe correction and leave implementation,
commits and shipping to the builder session.

## What to weight in this repository

Replace this list with what can go wrong here. The defaults:

- **The rails themselves.** `scripts/gate.sh`, `.github/workflows/`,
  `.claude/hooks/`: a weakened rule, a check that fails open, a filter that
  checks nothing and exits 0. That is a finding, not a cleanup.
- **Secrets and synthetic-only fixtures.** Anything in a fixture, test or
  recording that could be real customer content, a real person or a
  credential.
- **Spec drift.** A diff that does what its PLAN.md paragraph never asked, or
  skips what it did.
- **Supply chain.** An action unpinned from its SHA, a dependency added
  without a hash, a workflow permission widened.
