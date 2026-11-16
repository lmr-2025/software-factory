#!/usr/bin/env bash
# PreToolUse(tracker MCP) — the issue-tracker write rail.
#
# Sessions own the ticket lifecycle: they close, cancel, re-home and comment on
# tickets themselves, with the evidence in the comment. The line this hook
# draws is the stop bar in CLAUDE.md: anything with no undo, anything that
# leaves the workspace, anything that merges code.
#   - delete_*                 : no undo
#   - share / unshare          : an issue leaving the workspace
#   - *attachment* uploads     : local bytes leaving the machine
#   - diff mutations           : PR control belongs to /ship, not the tracker
#   - retire_*_label           : a workspace-wide change
#   - a new `finding: v1` issue with neither a `fix: <PR url>` line nor a
#     `not-a-diff: <reason>` line: a finding defaults to a fix, not a record
# Everything else passes. An unparseable payload is refused.
#
# Written against the Linear MCP tool names. For another tracker, change the
# TRACKER pattern and the tool-name globs below; the classes stay the same.

set -uo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/_common.sh"

TRACKER='Linear__'

read_payload   # refuses (exit 2) on an empty or invalid payload
tool="$(field '.tool_name')"
[[ -z "$tool" ]] && block "TRACKER WRITE GUARD: missing tool_name; refusing to approve a write it cannot classify."

case "$tool" in
  *"$TRACKER"*) ;;
  *) exit 0 ;;   # not a tracker tool
esac

# Reads pass first, so a read named like a refused class (get_attachment,
# list_diffs) is never blocked.
case "$tool" in
  *"$TRACKER"get_*|*"$TRACKER"list_*|*"$TRACKER"search_*|*"$TRACKER"read_*|*"$TRACKER"extract_*)
      exit 0 ;;
esac

case "$tool" in
  *"$TRACKER"delete_*)
      block "TRACKER WRITE GUARD: '$tool' has no undo. Resolve, cancel or edit instead; a real delete is the owner's." ;;
  *"$TRACKER"share_issue|*"$TRACKER"unshare_issue)
      block "TRACKER WRITE GUARD: '$tool' moves an issue across the workspace boundary. That is the owner's call (CLAUDE.md § the stop bar)." ;;
  *"$TRACKER"*attachment*)
      block "TRACKER WRITE GUARD: '$tool' sends local bytes to the tracker. Link the file by URL in a comment instead." ;;
  *"$TRACKER"*diff*)
      block "TRACKER WRITE GUARD: '$tool' changes a PR through the tracker. Merging, reviewing and updating a PR belong to /ship." ;;
  *"$TRACKER"retire_issue_label|*"$TRACKER"retire_project_label)
      block "TRACKER WRITE GUARD: '$tool' retires a workspace-wide label, which changes every ticket wearing it. Bring it to the owner." ;;
esac

# A create (no `id`) that opens a finding carries the fix's PR on its own
# `fix:` line, or says on a `not-a-diff:` line why it cannot be one. A PR link
# elsewhere in the body (the one that introduced the defect, say) is evidence,
# not a fix. Updates to an existing finding pass.
if [[ "$tool" == *"$TRACKER"save_issue && -z "$(field '.tool_input.id')" ]]; then
  body="$(field '.tool_input.description')"
  if grep -q 'finding: v1' <<<"$body" \
     && ! grep -qE '^[[:space:]*-]*(fix:[[:space:]]*<?https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+/pull/[0-9]+/?>?[[:space:]]*$|not-a-diff:[[:space:]]*[^[:space:]])' <<<"$body"; then
    block "TRACKER WRITE GUARD: a finding defaults to a fix, not a record. Build the fix and put its PR on its own line as 'fix: https://github.com/<owner>/<repo>/pull/<n>', or add a 'not-a-diff: <reason>' line saying why it cannot be one (the owner's call, an external wait, out of reach)."
  fi
fi

exit 0
