---
name: pick-up-work
description: How a session picks up work and drives it. Use on "pick up a batch", "let's tackle X", "go", an idle session with no directed task, or whenever you are about to choose what to work on. No ticket is un-pickable; only the escape boundary is a wall.
---

# /pick-up-work — intake

The queue is `PLAN.md` § The sequence, top-down, and its tickets. This skill is an on-ramp, not a gate: returning from it is never the end of a turn.

## 1. Read the grant from how the owner asked

Two things are read separately: **dispatch mode** (fan out and run to a draft PR?) and **fork authority** (decide an owner's fork solo?). Batch wording grants the first, never the second.

- Dispatch-autonomous: "pick up a batch", "orchestrate with subagents", "one draft PR", "run with this", "go". Fan out, run to the deliverable, carry decisions into the PR body.
- Collaborative: "let's tackle", "can we", a question, a soft single ask. Bring forks to the owner as you hit them.
- Ambiguous: collaborative.
- A present owner's product-model, taste or one-way-door fork always waits for them. Owner away: the batch runs on recommended answers with the question sheet in the deliverable. Technical, reversible forks are decided in either mode and recorded in the PR's Decisions section.

A grant flips the mode for the session. A batch request with no sign of whether the owner is around gets one availability question, not a fork-by-fork round trip.

## 2. The core rule

No ticket is un-pickable. "Needs a brainstorm", "has a fork", "needs the owner" are engagement types: the brainstorm is the first step, the fork gets a recommendation, an owner's gate is a shepherding verb ("walk them through X, get the go, drive the rest"). The only walls are the escape boundary: production or cloud changes, spend past standing authority, a one-way door, anything leaving the repo. Refusing a ticket because it needs a brainstorm you could run fails the honest-stop bar in CLAUDE.md.

## 3. The loop: pick, claim, classify, engage, flow on

**Pick:** in-flight work first; then a pickup note left by an earlier session; then the queue top-down (an open paragraph with no ticket is the bug: file the ticket, then pick it); then an open fork you can bring a recommendation on.

**Name the tests, then claim.** Before engaging or dispatching, write the NORTH-STAR tests the work moves toward and must not break at the top of the per-run checklist. Then claim the ticket (move it to In Progress) so a concurrent session does not take the same work.

**Keep a per-run checklist** in scratch, not in the repo: one line per piece of the paragraph with its Done-when, ticked as each lands. Context compacts on long runs; the checklist survives and is what a pickup reads first.

**Classify and engage:**

| Type | How |
|---|---|
| brainstorm-gated | Run `/brainstorm` here, with the owner if present, solo to spec if not. |
| spend-gated | Announce each spend with a running total before it happens, within the standing authority the owner set. |
| fork for the owner | Decide with a recommendation; present means they react, autonomous means decided, recorded, landed at a seam. |
| multi-piece | The paragraph names the pieces in order with a Done-when each. Dispatch one pinned-cheap builder per piece, review each returned branch against the paragraph, then `/ship`. |
| single mechanical piece | One builder, model named (`.claude/MODEL-GUIDE.md`). The builder's deliverable is a pushed branch, never a PR; this session opens the draft. |
| judgment-heavy | Keep it here. If the subagent would need a judgment call, it is not subagent work. |
| ungated single | Drive to `/ship`. |
| escape boundary | Surface with a recommendation, do not cross, keep going on other work. |

**A builder brief isolates the builder.** It names the builder's own worktree and its own scratch directory, and forbids `git stash`, `git checkout -- .`, `git reset --hard` and `git clean` (a baseline is `git show HEAD:<path>` or a scratch worktree). Commit your own edits before dispatching into a worktree, and make none there until the builder returns. A builder's bare stash can take the orchestrator's uncommitted work; builders sharing one scratch directory overwrite each other's files.

A message from the owner mid-run is re-read against the open paragraph; a builder already dispatched finishes its piece before the change applies.

**Flow on.** Reviewing a returned branch is the next iteration. After a piece lands, take the next pickable thing.

## 4. Exits, none of which ends the turn by itself

- Context running out at a clean seam: a unit committed or PR'd, the next action crisp and its wall verified at the source. Write a pickup note and a short handoff, then stop.
- The queue genuinely dry, after looking wider than the first source.
- A blocking wall with nothing else pickable.
