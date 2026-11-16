# Model tiering for subagents

**The one rule: expensive decides, cheap executes, the expensive orchestrator reviews.** A subagent inherits the session model unless `model` is named on the dispatch, which bills every fan-out at top rates and is the wrong tier for execution work. `pre-tool-model-guard.sh` blocks any dispatch that omits `model` (forks are exempt because the client ignores the field for them). An explicit model, top tier included, passes: a named tier is an auditable choice.

| Work | Model |
|---|---|
| Design, brainstorm, fork decisions, plan authoring, **reviewing subagent output** | the main session (don't delegate judgment) |
| Hard reasoning, or a from-scratch build that is closer to design than to a plan | the top reasoning tier, named |
| Checklist or standards review, mechanical edits from an explicit spec, test and doc writing | the mid tier |
| Search, explore, enumerate, "find where X lives" | the cheapest tier |

**The review step is not optional.** Cheap tiers are safe only because the orchestrator verifies what comes back. A high-stakes step that merely looks mechanical (deciding whether a branch is merged before deleting it, say) gets a capable model and the orchestrator's own check. Hand cheap tiers extracted, specific context: paths, the exact checklist, the output shape. They fail on ambiguity, not on volume.
