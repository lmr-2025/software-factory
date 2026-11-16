# How it works

## The loop

1. **The canon.** `NORTH-STAR.md` holds numbered tests a person could check by hand. `PLAN.md` holds one paragraph per piece of work, and that paragraph is the whole spec: what it makes runnable, what it decided and why, and a Done-when the gate can run. The tracker holds one line per paragraph and nothing else, because two copies of a spec drift and the paragraph wins.
2. **Intake** (`/pick-up-work`). A session takes the top of the queue, names the tests the work moves toward and must not break, claims the ticket, and keeps a per-run checklist in scratch so a long run survives context compaction.
3. **Design when needed** (`/brainstorm`). A new shape gets a paragraph before code. Precedent that already covers the work skips the design gate. The session decides every fork it can and flags only the ones that are the owner's.
4. **Build in a worktree.** Never on the shared checkout. Subagents get a named model, their own worktree and their own scratch directory, and they end at a pushed branch.
5. **Ship** (`/ship`). The real test from the branch, then the gate (a verbatim mirror of CI), the log line in the same commit, a draft PR whose body opens with the decisions, the session's own whole-diff review, a second-opinion review from a different model, one comment adjudicating every finding, then ready, CI, merge.
6. **Learn.** Anything that went wrong is logged in one line. A cold session later clusters the log, and whatever recurred across sessions becomes a rail where the mistake happens.

## The doctrine, in four rules

**Execution mode is the default.** Deciding is work. A session stops only for a one-way door, spend past its authority, or a product-model or taste call, and it arrives with a recommendation.

**Decisions, not forks.** Two classes belong to the owner by authority: the stop bar (spend, cloud changes, anything leaving the repo, one-way doors) and what only they hold (product direction, the product model, taste, what counts as true). Everything else is the session's, decided by three tests in order: is one option just worse on evidence; does the canon already point; is the open question a fact you can check. A tie that survives all three is a coin flip, and the session flips it. A fork the canon couldn't settle is a gap in the canon: decide it, then add the one line that would have settled it.

**Verify before claiming.** `gh pr view`, `git log`, the running system. Never a note, a memory or a comment.

**Plan more, build less.** Long planning costs hours; building the wrong thing costs weeks.

## Why each rail exists

Every hook below was added after the same mistake happened more than once. The pattern behind each is general enough that it will happen to you too.

**No commits on the shared checkout.** With several sessions on one machine, the main checkout's HEAD is whatever the last session left. A commit there lands on someone else's branch. Worktrees give every session its own.

**No killing processes by name.** A `pkill -f <test runner>` meant for one session's run also kills every other session's, and can miss the children it meant to stop, which then keep running beside the next run.

**Draft PRs only, and only through `/ship`.** The steps before the PR (gate, log line, title fields) were skipped whenever a session opened the PR by hand. The hook makes the PR the tail of a ship run, proved by a marker file under six hours old.

**The second-opinion review can't be skipped or faked.** Sessions opened PRs and ended without the review, or reviewed an older commit than the one they pushed. The Stop hook checks every recent draft for an adjudication comment naming the current head. The review wrapper refuses to run until the session has posted its own whole-diff review, because reviewing only each new fix is how one PR took nine rounds.

**Subagents name their model.** A dispatch with no model inherits the session's, which is usually the most expensive tier. Search and mechanical builds don't need it. The orchestrator reviews what comes back; that is what makes the cheap tier safe.

**Tracker writes with no undo are blocked.** Sessions own the queue (they close, move and comment on tickets themselves, because waiting on the owner for clicks stalls everything), but a delete has no undo and a share leaves the workspace. A finding filed without a fix is also refused: sessions kept writing the fix into a ticket and building none.

**Protected data can't be deleted.** One `docker compose down -v` aimed at the wrong project can take a customer's data. The hook knows a protected directory by a marker file and a protected volume by its name prefix.

**Hooks fail closed.** An early version of these hooks read the tool input from an environment variable that didn't exist, got an empty string, matched nothing, and approved everything for weeks. Now an empty or unparseable payload blocks.

**The gate mirrors CI exactly.** Drafts get no CI (it would rerun on every push nobody is waiting for), so the local gate is a draft's only evidence. Any gap between the two lands on whoever flips the PR ready.

**Actions pinned by SHA, gitleaks by checksum.** A tag can be moved to different code; a commit can't. Dependabot moves the pins weekly so exact pins don't become stale ones.

**The leak check.** Client names, private links and home-directory paths reach a tree through examples, comments and copied logs. The generic shapes are committed; the names themselves stay in a gitignored file on your machine, because a committed list of client names is itself a leak.

## Lessons become rails

`log-lesson.sh` deposits one row with no judgment. `/promote-lessons`, run in a fresh session so it isn't defending its own incident, clusters rows and counts distinct sessions. One occurrence stays in the log as live evidence. Two or more get routed to whatever fires at the moment the mistake would happen: a gate check if a grep can catch it, a hook if it happens while running a command, a line in the skill that owns that kind of file if it happens while editing one. CLAUDE.md is the last resort, because every line there is paid on every turn. "Remembered by Claude" is not a category.

## Adapting it

Start with `CLAUDE.md`, the worktree guard, the PR gate and `/ship`. Those four carry most of the value. Add the review seat once things are merging faster than you can read them, and the lesson loop once you notice the same correction twice.
