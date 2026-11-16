---
name: cto-brief
description: Brief the owner from zero, as the CTO who held the program while they were away — verified live, against the plan, ending with a recommendation and a question. Read-only. Use on "catch me up", "where are we", "brief me", "be the CTO".
---

# /cto-brief

The owner has been away and has not watched the work. Earn the thread from live truth, then hand it back: where we are, against the plan, what is next, and, only if one exists, the call that is genuinely theirs. This skill changes nothing: not the tree, the tracker, or a PR. `orient` grounds a reviewer, `ops-cleanup` reconciles records, `pick-up-work` executes; this one reads and reports.

**Brief from zero.** No "as we discussed", no "still waiting on your reactions", no decision framed as a debt they owe. An open decision is presented fresh, with the context to settle it in one read.

**Verify live, never from the written state.** `PLAN.md`, pickup notes and tickets are claims. Every headline is one you confirmed this session; where the record and live truth disagree, that is a line tagged *drift*, and the fix is `ops-cleanup`, recommended, not run here.

## The pass

1. **Read the plan of record:** NORTH-STAR (the numbered tests), `PLAN.md` (each paragraph's Done-when and status, the open forks).
2. **Snapshot live state, read-only:**
   ```bash
   git fetch origin main -q && git log origin/main --oneline -15
   gh pr list --state all --limit 30 --json number,state,isDraft,title --jq '.[] | "\(.number) \(.state) draft=\(.isDraft) \(.title)"'
   git worktree list
   ```
   Then the tracker's In Progress and the top of the queue. If a running instance is up, sample it; shipped is not the same as works. If none is, say the brief rests on merged PRs.
3. **Reconcile.** Each piece the plan calls done: `gh pr view <n> --json state` says MERGED, or it is drift. The open paragraph's Done-when against live state: met, partway, or not started.

## The fork bar

A fork reaches the brief only when it clears the stop bar (CLAUDE.md § Decisions, not forks) and gates what you would do next. Everything else you decided: report it as done. Do not manufacture a call to fill a section; "nothing needs you, here is what I am doing next" is the healthy ending.

## The brief

Spoken in the session, tight and ranked. Four parts always, a fifth only if the bar was cleared:

1. **Where we are.** One honest paragraph.
2. **Against the plan.** What landed, the open paragraph and its Done-when, which NORTH-STAR tests read yes and which still fail. Cite, don't restate.
3. **Drift found.** Record versus live. "None" is a valid finding.
4. **What's next.** One to three candidates, one line each, and the one you recommend with the reason.
5. **What needs you.** Only if a fork cleared the bar: the decision, the context, your recommendation.

End with the question, not the work: go (hand to `pick-up-work` on the recommended item), clean up first (`ops-cleanup`), or hold.
