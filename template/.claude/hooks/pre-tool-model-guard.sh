#!/usr/bin/env bash
# PreToolUse(Agent|Task) — every subagent dispatch names its model.
#
# An omitted `model` silently inherits the session model, which is usually the
# most expensive tier and the wrong one for search, enumeration, checklist
# review and mechanical builds. Only omission (or `inherit`) is blocked; an
# explicit model, the top tier included, is an auditable choice and passes.
# Forks are exempt because the client ignores the field for them.
# See .claude/MODEL-GUIDE.md.

set -uo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/_common.sh"

read_payload

# The dispatch tool is `Agent`; `Task` is a legacy alias. Match both so the
# rail survives a rename in either direction.
case "$(field '.tool_name')" in
  Agent | Task) ;;
  *) exit 0 ;;
esac

model="$(field '.tool_input.model')"
subagent="$(field '.tool_input.subagent_type')"

# A fork always inherits the parent model; the client ignores `model` for it.
[[ "$subagent" == "fork" ]] && exit 0

# `inherit` resolves to the session model, which is exactly the fallback this
# hook exists to block, so it is treated like an omitted model.
if [[ -z "$model" || "$model" == "null" || "$model" == "inherit" ]]; then
  block "Blocked: Agent dispatch to '${subagent:-?}' omitted \`model\` (or named \`inherit\`), so it would silently inherit the session model. Name a tier: a cheap one for search, enumeration, checklist review and mechanical builds; the top tier only for hard reasoning. See .claude/MODEL-GUIDE.md."
fi

exit 0
