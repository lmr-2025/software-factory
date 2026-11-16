# <project> — Claude instructions

**This file routes; it does not teach.** The goal page is [`NORTH-STAR.md`](NORTH-STAR.md): before any piece of work (a spike or a brainstorm as much as a feature), name the tests it moves toward and the tests it must not break. The program's state is [`PLAN.md`](PLAN.md): open on it, and update it in the same session as the work. The record is [`docs/LOG.md`](docs/LOG.md): one dated line per merged PR, written in the same commit as the work.

<!-- Fill in: who "the owner" is (the person whose calls are listed under the stop bar), the tracker, and the hard rules specific to this repository. Delete this comment. -->

## Hard rules that hold from commit one

- **No secrets in history.** gitleaks runs in the gate and in CI; push protection is on.
- **Every fixture is synthetic.** No customer content, no real person, no real repository in history. Examples use a made-up company (Northwind).
- **No PR without the three fields** on its title's first line: *makes runnable:* (a NORTH-STAR test or Done-means line) · *imports:* nothing (or what came in, defended) · *size:* lines. The body opens with `## Decisions`.
- **The tracker is the queue, never the spec.** The spec is the paragraph on `PLAN.md`; its ticket is one line pointing at it. A PR body says `Part of <ticket>` or `Closes <ticket>`.
- **Branch protection on `main`.** Everything lands through a PR from a worktree. A PR opens as a draft (CI does not run on drafts; the local gate is the draft's evidence). The session that opened it flips it ready and merges once the gate is green and the advisory review is adjudicated. A PR that changes the rules themselves (this file, the hooks, the ship skill) flips ready and waits for the owner to merge. The owner's authority is direction, spend, cloud state and anything that leaves the repo.

## Working style (the rails are hooks in `.claude/`; the doctrine is this section)

**Execution mode is the default.** If there is work to do, do the work, and deciding is work. Status notes go in the same message as the next action, never as a turn of their own. A stop must survive "could a competent CTO resolve this without the CEO?": only a one-way door, spend past authority, or a product-model or taste fork clears it, and it arrives with a recommendation.

**Verify before claiming.** `gh pr view`, `git log`, the running system, the gate's own report. Never a memory, a note or a comment.

**Terminal state is a merged PR.** Gate green, advisory review adjudicated in one marker-headed comment, ready-flipped and merged by the session. Every cloud mutation is the owner's, with one named exception: tracker writes (state, project, comments) are the session's, because the queue is how sessions coordinate. The write guard refuses only what has no undo or leaves the workspace.

**Concurrent sessions share the machine.** Author in a worktree, stage by path, kill processes by pid, never by name.

**Plan more, build less.** A new shape gets `/brainstorm`, which ends in a paragraph on `PLAN.md` before any code. When handing the owner a design to approve, present it as a private review page (decision, forks, evidence, worked examples), not a terminal dump. Routine progress and quick answers stay in the terminal.

**Long sessions are the top cost driver.** Keep a per-run checklist in scratch so compaction loses nothing, and recommend a fresh session when a deliverable closes, after writing the pickup note.

**Subagents name their model** on every dispatch (`.claude/MODEL-GUIDE.md`; the guard blocks omission). Builders end at a pushed branch; the orchestrating session opens the PR.

The full sequence is [`.claude/skills/ship/SKILL.md`](.claude/skills/ship/SKILL.md).

## Why we document

For the owner to understand and for the next session to understand. That is the whole list; nothing is written for a third reader.

## Decisions, not forks

A session with the canon (NORTH-STAR.md, PLAN.md and this file) in front of it has enough to decide everything inside the repo. Every PR body carries a *Decisions* section: what was decided, why, defended as if challenged. No menu, no "flip by", no question. A fork (two strong choices the canon could not pick between) is a defect in the canon, not an output: decide it, then add the one line that would have decided it to its one home (a product-model line to NORTH-STAR, a mechanism to a test or a ceiling, a process rail to this file) and nowhere else.

**Gate on authority first, then apply the three tests.** Two classes are the owner's by authority and never enter the filter, however clear the evidence: (a) **the stop bar**: spend past authority, a cloud or external mutation (tracker writes excepted), anything leaving the repo, a one-way door; and (b) **what only the owner holds**: product direction, the product model, taste, ownership, and what counts as true. Those reach the owner with a recommendation.

The tests apply **only to a reversible call already inside the session's authority** (technical, execution, mechanism):

1. **Evidence.** Is one branch just worse on the measured evidence? Then decide it.
2. **Canon.** Does NORTH-STAR, PLAN.md or this file already point? Then follow it and note the assumption.
3. **Fact.** Is the open part a fact you can check rather than a choice the owner makes? Then check it, don't ask.

A reversible technical tie that survives all three is yours to break: pick one, note it, move on. A coin-flip is not a fork. "Notable decision" is not "the owner's fork": informing them belongs in the PR's Decisions section.

## Lessons become rails

When something goes wrong, deposit it with `.claude/scripts/log-lesson.sh "<class>" "<what happened and the corrective>"`. Don't judge it in the moment. A cold `/promote-lessons` pass later clusters the log, and anything that recurred across sessions earns a rail at the point where the mistake happens: a gate check, a hook, or a line in the skill that owns that kind of file. "Remembered by Claude" is not a category, and this file is the last place a lesson goes, because every line here is paid on every turn.
