#!/usr/bin/env bash
# Shared helpers for Claude Code command hooks.
#
# Contract (per Claude Code hooks docs):
#   - Tool input arrives as JSON on STDIN, never in env vars. The
#     $CLAUDE_TOOL_INPUT / $CLAUDE_TOOL_INPUT_FILE_PATH vars do not exist.
#   - Payload has top-level `cwd`, `tool_name`, `tool_input`.
#   - PreToolUse: exit 2 blocks the call, stderr is fed back to Claude.
#     PostToolUse: exit 2 CANNOT undo the action; stderr surfaces as a warning.
#
# Every hook sources this, then calls `read_payload` exactly once.

set -uo pipefail

# Written by read_payload.
PAYLOAD=""
HOOK_CWD=""

# Block the tool call with a message. Only meaningful in PreToolUse.
block() {
  echo "$*" >&2
  exit 2
}

# Slurp stdin and fail closed. An empty or unparseable payload must never
# silently approve — that is the exact failure mode that kept these hooks
# inert (empty read -> no match -> exit 0 -> approve).
read_payload() {
  PAYLOAD="$(cat)"

  # NOTE: must stay the regex form. The substitution form ${PAYLOAD//[[:space:]]/}
  # is quadratic on large payloads — a 30KB Write took 58s PER HOOK (x3 hooks per
  # Write ≈ 3min hang). The regex stops at the first
  # non-space byte.
  if ! [[ "$PAYLOAD" =~ [^[:space:]] ]]; then
    block "Hook aborted: empty stdin payload. Refusing to approve by default."
  fi

  if ! jq -e . >/dev/null 2>&1 <<<"$PAYLOAD"; then
    block "Hook aborted: stdin payload is not valid JSON. Refusing to approve by default."
  fi

  HOOK_CWD="$(jq -r '.cwd // empty' <<<"$PAYLOAD")"
}

# Read a field out of the payload. Empty string if absent.
field() {
  jq -r "$1 // empty" <<<"$PAYLOAD"
}

# The git repo that the tool call is actually happening in.
#
# Resolve the repo from the payload's cwd, so a hook judges the tree the tool
# call is really touching — never whichever checkout the hook file happens to
# live in.
#
# Falls back to $CLAUDE_PROJECT_DIR, then to the hook script's own repo.
repo_root() {
  local start="${HOOK_CWD:-}"
  [[ -z "$start" || ! -d "$start" ]] && start="${CLAUDE_PROJECT_DIR:-}"
  [[ -z "$start" || ! -d "$start" ]] && start="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

  git -C "$start" rev-parse --show-toplevel 2>/dev/null
}
