# software-factory

vibe coding for adults

A small, opinionated kit for building software with Claude Code as the main builder and a person as the owner. It is the working layer from a solo founder's repositories: the doctrine that tells sessions how to decide, the hooks that stop the mistakes that kept recurring, the skills that carry each recurring job, and the gate and CI that make "done" mean something.

It assumes one owner who sets direction and many sessions (sometimes running at once) that do the building. The owner's time is the scarce resource, so the kit pushes every reversible decision to the session and keeps only a short, explicit list for the owner.

## What's in it

```
template/                         copy this into your repository
  CLAUDE.md                       the doctrine: execution mode, decisions not forks, the stop bar
  NORTH-STAR.md                   the goal page: numbered tests every piece of work is held against
  PLAN.md                         the program's state; one paragraph per piece of work is the spec
  AGENTS.md                       the contract for the second-opinion reviewer
  docs/LOG.md                     one dated line per merged PR
  .claude/settings.json           wires the hooks
  .claude/MODEL-GUIDE.md          which model tier does which kind of subagent work
  .claude/hooks/                  the guardrails (below)
  .claude/scripts/                lesson and fork loggers, the second-opinion review wrapper
  .claude/skills/                 17 skills (below)
  .codex/review-output.schema.json  the reviewer's JSON output shape
  scripts/gate.sh                 the local gate, a verbatim mirror of CI
  scripts/leak_check.sh           fails the gate when an internal name or link reaches the tree
  .github/workflows/ci.yml        SHA-pinned actions, read-only permissions, gitleaks by checksum
  .github/dependabot.yml          moves the pins weekly
  .gitleaks.toml, .leak-patterns, .leak-denylist.example, .gitignore
docs/how-it-works.md              the loop, and why each rail exists
```

### The guardrails (hooks)

| Hook | What it stops |
|---|---|
| `pre-bash-worktree-guard.sh` | committing or branching on the shared main checkout; killing processes by name |
| `pre-bash-pr-gate.sh` | opening a PR that isn't a draft, or that skipped `/ship` |
| `stop-ship-choreography.sh` | ending a session with a draft PR whose second-opinion review was never run or adjudicated |
| `pre-tool-model-guard.sh` | dispatching a subagent without naming its model |
| `pre-tool-tracker-write-guard.sh` | tracker writes with no undo (deletes), that leave the workspace, or that merge code |
| `pre-bash-protected-data-guard.sh` | deleting data marked as the owner's to remove |

Every hook fails closed: an empty or unreadable payload blocks rather than approves (`_common.sh`), except the Stop hook, which fails open so a network blip never traps a session.

### The skills

| Skill | Job |
|---|---|
| `ship` | the Definition-of-Done: gate, record, draft PR, whole-diff review, second opinion adjudicated, ready, merge |
| `brainstorm` | an idea becomes a spec paragraph, with the owner's forks decided provisionally and flagged |
| `big-brain` | thinking-out-loud mode; no building |
| `pick-up-work` | intake: how a session chooses work and engages it; "needs a brainstorm" is never a reason to skip a ticket |
| `promote-lessons` | a cold pass that turns repeated mistakes into rails |
| `cto-brief` | catch the owner up from zero, verified live |
| `ops-cleanup` | make every record (branches, worktrees, tickets, notes) match live state |
| `diagnose` | instrument-first debugging: a feedback loop before a theory |
| `fold-prs` | combine several draft PRs into one, gated once |
| `security-review` | adversarial security review of a diff |
| `review-seat` | post-merge review, one lens per pass |
| `orient`, `correctness-review`, `altitude-review`, `architecture-health` | the review seat's lenses |
| `collaborative-drafting` | editor, not ghostwriter, for the owner's own writing |
| `publish-check` | the check before anything goes into a public repo |

## Install

1. Copy `template/` into the root of your repository (merge with any existing `.gitignore` and `.github/`).
2. Fill in the three canon files: the header of `CLAUDE.md`, the tests in `NORTH-STAR.md`, the first paragraph in `PLAN.md`. Delete the examples.
3. Edit `scripts/gate.sh` and the `gate` job in `.github/workflows/ci.yml` to run your project's own lint and tests, keeping the two identical.
4. Copy `.leak-denylist.example` to `.leak-denylist` and list your clients, partners, people and private repos. It is gitignored on purpose.
5. Install the tools the hooks and gate call: `jq`, `gh` (signed in), `gitleaks`, and the Codex CLI if you use the second-opinion review.
6. If your tracker isn't Linear, change the `TRACKER` pattern in `pre-tool-tracker-write-guard.sh` and the matcher in `.claude/settings.json`.
7. Turn on branch protection for `main` with the `gate` and `secret-scan` checks required.
8. Start a session and ask it to run `/orient`, then `/pick-up-work`.

The kit works without Codex: replace step 6 of `/ship` with another independent reviewer (a fresh Claude session with no context works) and keep the same marker comments.

## What it is not

Not a framework or a dependency: it is files you own and change. Not tied to a language: the hooks are bash and `jq`, the gate is a template. It does not cover multi-session claim coordination beyond worktrees and tracker status, or cloud deploys; those parts of the original setup were too specific to one machine to share.

## GRC skills

Domain skills for governance, risk and compliance work (incident-response and business-continuity tabletop exercises, with more to come) live in [GRC Skills](https://github.com/Checkbox-Compliance/grc-skills).

## License

MIT. See [LICENSE](LICENSE).
