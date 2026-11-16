---
name: security-review
description: Claude-owned security review. SAST mode runs semgrep locally if installed and triages; FULL mode is an adversarial diff review with a Required/Recommended/Not-required rating. Use before shipping auth, tenant-isolation, endpoint, credential or ingress work, or on "is this secure".
---

# /security-review

Claude is the security reviewer. Findings go to the user with the exploit scenario and the fix; bringing in an outside reviewer is the user's call, offered only for a Required finding that turns on acceptable risk rather than a fixable bug.

## SAST mode (`/security-review sast [diff]`)

CI runs gitleaks; nothing else produces these findings. No semgrep on PATH means SAST is a no-op: say so and run FULL. Setup: `pip3 install --user semgrep`; always pass `--metrics=off`.

1. Scope: `diff` (files changed against `origin/main`) or the source tree.
2. Run:
   ```
   semgrep --config=p/security-audit --config=p/secrets --config=p/<language> --severity=ERROR --severity=WARNING --json --output=<scratch>/semgrep-out.json --metrics=off --quiet <targets>
   ```
3. Summarise with `jq` by severity and rule with `file:line`. Never dump raw JSON, and never put a subagent between the scan and the file.
4. Triage each finding by reading the site. True positive: fix now. False positive (proximity, not data flow): suppress inline with `# nosemgrep: <rule-id> — <reason>`. Accepted risk: one line in the PR body.
5. Report totals, verdicts, next action.

## FULL mode (`/security-review [<PR-url>]`)

Diff-scoped, adversarial, not a correctness review. Keep it rare and real.

1. Diff: `git fetch origin main && git diff origin/main...HEAD`, or `gh pr diff <url>`.
2. SAST first if available.
3. Review against this system's trust model. Replace these with your own:
   - **Tenant isolation.** Any new read, cache, projection or prompt context that reaches across customers.
   - **Authn and authz.** A new route or action missing its permission check; key handling.
   - **Trust boundary.** A new endpoint doing something powerful (fetching a URL, accepting an upload, calling out); untrusted input reaching a dangerous sink.
   - **Secrets.** Stored, logged or forwarded; check what is actually logged.
   - **LLM boundary.** A model call outside the one place model calls live; untrusted content reaching a prompt as instruction.
   - **Supply chain.** Workflow YAML, Dockerfiles, manifests: installs frozen, images pinned by digest, actions pinned by SHA, least-privilege permissions.
   - **Fail-open defaults.** `env.get('KEY') or 'default'` on anything security-bearing is fail-open; a hard error is correct. Probe the zero, empty and null edges of every new security parameter.
   - **Removed security code.** A check deleted in "just a refactor" is a candidate regression until shown otherwise.
4. Verify each candidate adversarially: restate it in one sentence (exact sink, input, impact), name who could trigger it, then try to refute it. Drop what you cannot show is exploitable. A finding needs a concrete exploit scenario: payload, path, preconditions, outcome.
5. Rate: **Required** (fix before merge), **Recommended**, **Not Required**.
6. Route to the user with file:line, who can trigger it, what they gain, and the fix.
7. Variant sweep: a confirmed finding is a class until proven singular. Grep the shape across the whole tree. A third instance earns a check in the gate.
8. Report: the rating, verified findings, what SAST covered, next action. A scanner that errored is UNAVAILABLE, never a pass.

## Rationalisations to reject

Small diff (classify by risk, not size). Production config overrides it (verify; the default is still a finding). It's behind authentication (a compromised session or a second tenant is an attacker). Similar code was safe elsewhere (different callers and guards). Just a refactor. Found one, fixed one, done.

Never push, open PRs or file tickets from this skill. Never report an unrefuted finding as Required.
