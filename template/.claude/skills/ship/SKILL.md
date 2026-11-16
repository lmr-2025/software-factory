---
name: ship
description: The Definition-of-Done — gate, record, marker, draft PR, whole-diff review, second-opinion review adjudicated, ready, CI, merge. Use on any end-of-work cue ("open a PR", "push this", "is this done?", "wrap this up") or a paragraph reaching its Done-when. A hand-rolled `gh pr create` skips the record, the marker and the review.
---

# /ship — the Definition-of-Done

Seven steps, in order. The PR gate hook (`pre-bash-pr-gate.sh`) rails steps 2 to 5 at `gh pr create`; the Stop hook (`stop-ship-choreography.sh`) rails step 6 at the session's end. Everything else is on you.

## 1. Stand on fresh main, and test for real

Author in a worktree, on a branch based on a **freshly fetched** `origin/main`. The local ref lies until fetched, and a gate run against a stale base grades the past.

```bash
git -C <worktree> fetch origin main
git -C <worktree> merge-base --is-ancestor origin/main HEAD && echo "based on current main"
```

Not an ancestor: rebase onto `origin/main` before running the gate. A dirty tree is not shippable; commit it or set it aside.

**The real test comes before the gate.** Code whose behaviour a unit test cannot see (a model call, a live API's schema, a deploy) runs for real from the branch first, with the cheapest real call that exercises it. A green suite on canned responses has shipped broken releases before.

## 2. The gate, green

`scripts/gate.sh` mirrors CI. If it takes more than a minute or two, run it detached and read the log rather than blocking:

```bash
cd <worktree> && nohup scripts/gate.sh --out .gate > .gate/run.log 2>&1 &
```

Then read the tail of `.gate/gate.log`; its last line is the verdict. **Green or stop.** A red gate is the work, not a caveat for the PR body. Never ship around it.

## 3. The record, in the same commit

Every PR adds one dated line to `docs/LOG.md`: what merged and the NORTH-STAR test it moved (or, for a process rail, the tests it must not break). It lands **in the same commit as the work**; a record in a follow-up commit is a record that can be dropped. If the work moved a paragraph's status on `PLAN.md`, opened a fork, or left residue, that goes on the paragraph, and every actionable residue also goes on its ticket. The queue is what the next session reads.

## 4. The PR title carries the three fields

The title's first line ends with the same three fields every builder brief carries:

```
· makes runnable: <a NORTH-STAR test or Done-means line> · imports: nothing · size: <lines>
```

`imports: nothing` is a claim you have to be able to defend.

## 5. Marker, then the draft PR; its body opens with `## Decisions`

Every call this PR made that a reader could have made differently: what, why, defended as if challenged. A clear path is stated as clear ("X, because Y"). No options, no "flip by", no question for the owner. Nothing to decide: one line saying so. **One decision, one home:** each line names where the decision lives (the NORTH-STAR test it follows, the test or ceiling that now enforces it, or this section when nothing can encode it), and it is written nowhere else. Five copies of one fact is how a settled decision becomes unfindable.

```bash
cd <worktree> && touch .claude-ship-run && gh pr create --draft --title "…" --body "…"
```

The marker is consumed by the create. One create per ship run. Draft is the only shape you open.

## 6. Review the whole diff, then the second opinion, adjudicated in one comment

**Review the whole PR by lens first, never only the latest fix.** Fixes reviewed one at a time is how a PR takes nine review rounds. Read `git diff origin/main...HEAD` whole, once per lens (for example: call paths and lifecycle; secrets and egress; UI and escaping). Over about 500 lines, dispatch parallel independent reviewers, model named, one per lens. Each enumerates every site of what it checks with `grep` (every caller of a changed function, every reader of a new field) and reports `file:line`, not impressions. Fix what they find. Picking up another session's draft is no exception: its review is a claim, so read the whole diff yourself.

Post that review as one PR comment headed:

```
orchestrator-review head=<sha>
```

Under it: the lenses read, the call sites enumerated, the findings, and the commit that fixed each. `codex_review_pr.py` refuses to run until a comment by someone with write access carries that marker for the current head.

```bash
python3 .claude/scripts/codex_review_pr.py --pr <n> --result .gate/codex-<n>.json
```

Read the findings from the result JSON (`.gate/` is gitignored). Then post **exactly one** comment headed with the marker the Stop hook looks for:

```
codex-advisory-review head=<sha>
```

Under it, adjudicate **every** finding:

- **accepted + fixed**: name the commit.
- **accepted + residue**: the fix is real but out of scope; write it onto the paragraph on `PLAN.md` and its ticket, and say so here.
- **rejected**: with the reason. "I disagree" is not a reason; the code path or contract it misread is.

A clean review still gets the comment, saying so. If the review genuinely cannot run, the one valid alternative is a `Codex advisory review BLOCKED: <the external precondition>` line in the PR body. A bare "deferred" is a skipped step.

## 7. Flip ready, watch CI, merge

With the gate green and every finding adjudicated:

```bash
gh pr ready <n> && gh pr checks <n> --watch && gh pr merge <n> --merge --delete-branch
```

CI runs once, on the ready PR. A red CI is the work: `scripts/gate.sh` mirrors it, and a gap between the two is a gate bug to fix in this PR. Never a cloud mutation; those are the owner's, with the exact command written down for them. **One exception:** a PR that changes the rules themselves (this skill, `CLAUDE.md`, the hooks) flips ready and waits for the owner to merge.

Report in this order: anything that needs the owner first, then the PR number, the merge SHA and the Decisions section, one line each. Then move the ticket and update your per-run checklist.
