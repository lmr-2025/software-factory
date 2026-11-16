---
name: publish-check
description: The check before anything goes into a public repository or leaves to an outside reader — commits, PR bodies, branch names, files, comments. Use before every push to a public repo, before sharing a package or export, or on "is this safe to publish".
---

# /publish-check

Treat every push to a public repository as publishing. History keeps what a later edit removes: a PR's edit history, a force-push timeline and GitHub's `refs/pull/N/head` all survive a rewrite. So the check runs before, never after.

## 1. Check visibility first

Before the first push to any repository, confirm whether it is public (`gh repo view --json visibility`). Public means everything below applies.

## 2. The owner's go before every commit, push, PR, comment or issue

Show the exact text and the file list, then wait.

## 3. What never goes in

- **Commits:** a plain message saying what changed. No links to private chat or session pages, no internal ticket ids, no "approved in the thread".
- **PR bodies:** what changed and why, nothing else. No mention of internal docs, private repositories, clients or who asked.
- **Branch names:** describe the change (`add-tabletop-skills`), never an internal session or ticket id.
- **Files:** synthetic examples only (a made-up company such as Northwind); no client names or data, no real people, no licensed standard text, no pointers to private repos, internal hostnames or home-directory paths. Read every file in full before it goes up.

## 4. The leak check, before every push

```bash
scripts/leak_check.sh                         # the tree, against .leak-patterns + your local .leak-denylist
git log --format=%B origin/main..HEAD | scripts/leak_check.sh /dev/stdin   # every commit message
gitleaks git --no-banner --redact .           # secrets
```

Then check the PR body text the same way. Any hit stops the push. Also check commit author emails (`git log --format='%ae' origin/main..HEAD | sort -u`): a personal address there is published too.

## 5. Open public PRs by hand

Some PR tools append their own footer or links to the body. For a public repository, push the branch and open the PR from the compare page (`https://github.com/<owner>/<repo>/compare/main...<branch>`), so the body is exactly what you checked. Read any comment back after posting it.

## 6. If something leaks

Stop and tell the owner. Editing or force-pushing does not erase it. The real fixes are theirs: recreate the repository from a clean tree, or have GitHub support purge the cached refs, and rotate anything secret.

## The cleanest public repository

A repository whose private history carries internal material cannot be made public by rewriting it. Publish a fresh repository from a cleaned tree, in one commit, and keep the private one as the archive.
