---
name: fold-prs
description: Fold several open draft PRs into one branch and one PR, then close the constituents. Use on "fold these PRs", "combine the drafts", "one PR instead of five". Owns the scope call, the conflict audit, the merge order, the single combined gate and the closeout.
---

# /fold-prs

One fold buys one CI run, one review and one revert unit. The spine: **shape the tree to its final form, then gate once.** Every re-gate ever paid for came from changing the tree after gating (a late main sync, a conflict fixed, a review finding patched). The only legitimate re-gate is a fix for a real defect the gate or a reviewer found.

## 1. Enumerate

The user's list is a starting point. List every open PR in range; note which have already merged and which belong to another session (find out whose before touching it).
```bash
gh pr list --state open --json number,title,isDraft,headRefName,files --jq '.[] | {n:.number,draft:.isDraft,head:.headRefName,files:(.files|length),t:.title}'
```

## 2. Audit conflicts before proposing a scope

Compute real file overlap:
```bash
for n in <numbers>; do gh pr view $n --json files --jq ".files[].path" | sed "s|^|$n |"; done > <scratch>/pr_files.txt
awk '{print $2}' <scratch>/pr_files.txt | sort | uniq -d | while read f; do echo -n "$f : "; grep " $f\$" <scratch>/pr_files.txt | awk '{print $1}' | tr '\n' ' '; echo; done
```
Additive docs fold fine. Edits to the same component fold with step 5 mandatory. A structural change and an additive one on the same file (one PR splits a module, another adds to it): recommend leaving the refactor out; it rebases onto the fold more cheaply than it merges in.

## 3. The scope call

The one genuine fork: all, all but the structural one, or two folds. Put it to the user with a recommendation. No structural conflict and an unambiguous ask: say so and proceed.

## 4. Build the final tree

A fresh worktree off `origin/main`:
```bash
git fetch origin && git worktree add ../wt-fold-<name> -b fold/<name> origin/main
```
Merge each constituent with `git merge --no-ff --no-edit origin/<branch>`, smallest first, resolving each conflict by hand as it happens. No squash or cherry-pick; the per-PR history is what the review reads. Then `origin/main` last, before any gate. Confirm `git status --porcelain` is empty.

## 5. Prove the tree

- **No conflict marker reaches a commit.** After every merge: `git diff --check` and `git grep -n -e '^<<<<<<< ' -e '^>>>>>>> ' -e '^=======$' -- ':!*.lock'` over the whole tree. Resolve each conflicted file individually, open it, confirm, and stage it by name. Never `git add -A` across an unverified conflict set.
- **The semantic conflict git cannot see.** Main moved or deleted a region, a branch edited it in the old place, and git keeps both: a function defined twice, an import that no longer resolves. Port the branch's intent onto main's new shape.
- **Line survival** on each file more than one PR touched:
  ```bash
  git diff origin/main...origin/<branch> -- <file> | grep '^+' | grep -v '^+++' | sed 's/^+//' | while IFS= read -r l; do [ -z "${l// }" ] && continue; grep -qF "$l" <file> || echo "MISSING: $l"; done
  ```
  Coarse: it proves no line vanished, not that the merge is right.

## 6. Gate once

The constituents' green does not transfer. Run `scripts/gate.sh` on the fold and read the last line of its log. Expect the union of the constituents' tests; a count matching one constituent means a merge dropped tests.

## 7. Review the combined diff

Per-constituent reviews prove the parts; one read of `origin/main...HEAD` proves the whole, since two PRs that are fine alone can interact badly. A defect the fold introduced is fixed here however large; a large fix to old code the fold merely touches is a follow-up.

## 8. Open through `/ship`

The body opens with what the fold changes, then a table of the constituents (PR, what it did, its pre-fold verification), the combined gate and review results, anything owed to the owner from any constituent in one list, any excluded PR and why, and notes on each semantic conflict.

## 9. Close the constituents

Each gets a comment naming the fold, then closes. Do not delete their branches; they are the restore path.

## Anti-patterns

Gating before the tree is final. Folding the user's list without the audit. Blanket-adding a conflict set. Trusting a clean auto-merge. Reusing constituent green. Deleting constituent branches. Hand-rolling `gh pr create`.
