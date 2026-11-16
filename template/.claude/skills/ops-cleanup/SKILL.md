---
name: ops-cleanup
description: Reconcile every record to live state — worktrees, local and remote branches, tickets, pickup notes, CLAUDE.md pointers. Use on "ops cleanup", "get current state", or when records look stale. It reconciles and cleans; it does not report or fill the queue.
---

# /ops-cleanup — make the records true

Build the live snapshot (git, PRs, worktrees, tickets), then reconcile each record to it. Deletion is a consequence of reconciliation, never the goal. It is safe mid-flight because it only removes what it proves landed.

**Every record is a claim.** Verify against live state before acting on it. Never delete a worktree or a branch, or close a ticket, because a note says it is done. Squash merges make git ancestry lie, so "is this on main" is answered by content (step 3), and tracker auto-close fires unreliably in both directions, so ticket state is read live.

**Run the verify steps yourself.** A cheap subagent hands back confident wrong verdicts on "is this landed", and a wrong verdict feeds a force-remove.

## Procedure

**0. Lessons first.** Count unpromoted rows in the lesson log (rows below the last `promoted-through` marker; don't read them). At 8 or more, recommend a cold `/promote-lessons` session.

**1. Snapshot live state.**
```bash
git fetch origin main -q && git rev-parse --short origin/main
gh pr list --state all --limit 30 --json number,state,isDraft,headRefName --jq '.[] | "\(.number) \(.state) draft=\(.isDraft) \(.headRefName)"'
git worktree list
git branch --format='%(refname:short)'
git remote prune origin && git branch -r
```

**2. Read every pickup note and in-progress ticket** in full.

**3. Is it landed? Stop at the first rung that answers.**
- Rung 0: `gh pr view <n> --json state`. MERGED ends the inquiry.
- Rung 1: own-line count, decisive only at 0:
  ```bash
  for b in <branches>; do own=0; for f in $(git diff --name-only "origin/main...$b"); do own=$((own+$(git diff "origin/main..$b" -- "$f" | wc -l))); done; echo "$b :: $own"; done
  ```
  Greater than 0 with no merged PR: genuinely open, keep it.
- Rung 2: per file, are the branch's added lines present on main? Near 100%, with a one-line reason per gap, means superseded.

**4. Reconcile the tracker.** For every ticket a merged PR touches, read the PR body (`Closes` closes; a bare mention only touches) and check the ticket's state against the substance. An In Progress ticket with no live branch or PR is a session that went dark: write a pickup note from the PR state and report it.

**5. Clean the tree.** `git worktree remove <path>` per merged worktree, then `git branch -D`. Never touch a worktree another live session holds. Keep any branch backing an open PR. Stage nothing you did not author.

**6. Prune remote branches.** Map each remote branch to its PR and apply the ladder. A merged branch is safe to delete only if its head still equals the PR's head at merge; a head that moved on gets the content test on the extra commits. No PR and nothing on main: flag it to the owner, never delete. Record each SHA before deleting (`git rev-parse origin/<branch>`) so `git push origin <sha>:refs/heads/<branch>` can restore it.

**7. Rewrite the pickup notes to only-true state.** Stale entries route, then go:

| What it is | Where it goes |
|---|---|
| Work that needs doing | a paragraph on `PLAN.md` and its ticket |
| Durable knowledge | a skill or doc, in a PR |
| An unfinished ticket for the next session | a pickup note |
| A hazard a session could hit today | a one-line warning, with a ticket if it lasts |

**8. CLAUDE.md and pointers.** Flag CLAUDE.md growing past about 200 lines (the owner trims it, not you). Check every file and script CLAUDE.md names exists, with one `ls`.

## Done

Every record verified live; worktrees and branches clean; tickets match PR state; pointers resolve. Report what you removed, kept and why, and anything for the owner.
