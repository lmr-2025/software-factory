---
name: brainstorm
description: Turn an idea into a spec paragraph on PLAN.md before building. Use for a new shape, a new LLM behaviour, a product-model change. Precedent that fully covers the work with no open fork skips the gate and builds.
---

# /brainstorm — the idea becomes a paragraph

The owner holds product direction and taste; the session owns the design and the technical pushback. The default is to run solo to a finished thought, then present once.

## Route first: which case?

- **A. Precedent covers it, no deciding fork.** Build directly, `/ship` to a draft PR, name the precedent in the report. No design gate.
- **B. Precedent covers the how, a deciding fork is open.** Run the brainstorm; follow precedent silently for the mechanics; make a provisional call on the fork; present with the fork flagged.
- **C. No precedent.** Run the brainstorm; the design is what the owner approves.

The gate (B and C) is the approval of a surfaced fork, not the running of the brainstorm. Needing one never parks the work. With the owner away, build on the recommended answers and the gate moves to the ready flip.

## Step 0: grill when the truth lives in the owner's head

When the design rests on a model only the owner holds (the product model, a rule's meaning, what counts as true) and the canon does not answer, solo design fabricates. Qualify each question: the canon, specs and code genuinely cannot answer it, and you attach a recommended answer. Owner present: one question at a time, ending when you restate the whole model and they confirm; the restatement lands in the canon in the same PR. Arriving from `/big-brain`: its closing grill already ran; design on that. Owner away: write the question sheet with recommended answers, adopt them, and open the spec with it. Skip Step 0 when the model is already written down.

## Run uninterrupted

- Follow documented precedent silently; a settled "how" is not a fork.
- Make provisional calls on the genuine forks and keep going.
- Present once, with the decided forks loud and reversible.
- Commit nothing until the owner reacts, if an owner's fork is open and they are present. If every fork turned out technical and reversible, build from the spec and carry the decisions into the PR body.

Interrupt early only when a fork's two branches lead to entirely different designs.

## Process

1. **Name the tests, then explore.** The first lines written are the NORTH-STAR tests this moves toward and the ones it must not break; every later step is held against them. Then the canon (NORTH-STAR, the paragraph, past decisions, recent commits, the code). First take within a few tool calls. Verify what already exists before scoping; a framing-changing finding is surfaced, not baked in. When a shared interface changes, enumerate every producer and consumer, tests included, before the mechanism settles. Every count in the spec is a query you ran; a subagent's count or structural claim is verified before it enters. Every claim about existing code carries file:line evidence read now. Then run `architecture-health`'s pre-build mode on the modules the work will touch.
2. **Scope check.** Spanning independent subsystems means decompose first.
3. **Frame check.** Why build this (trace to a NORTH-STAR test; a thin trace is a kill signal). What changes if it is built well (a concrete success state). Which non-technical forks exist (who sees it, what it commits us to naming, what it implies about trust and ownership), plus a blindspot scan: what would a domain expert or the customer flag?
4. **List the genuine forks** (product model, ownership, what is true, and any framing-changing finding). Everything precedent, canon, code or defaults settle is not a fork; resolve it silently and note the assumption.
5. **Propose two or three approaches** and lead with the recommendation. Design toward the code that should exist when the work lands, not the smallest diff from today. When the work settles a new interface, draft three alternatives under one constraint each (smallest interface; most flexible; the commonest caller's case trivial), compare them on depth, locality and seam placement, and carry one recommendation, not a menu. A question you cannot settle on paper (does this state model feel right, what should this screen look like) gets a throwaway prototype on a throwaway branch.
6. **Decide each fork provisionally, then attack your own call.** Steelman the alternative; flip if it wins; otherwise the surviving attack is the "why not" line. An attack that can only be answered by adding a mechanism or contradicting a named test is not accepted: the proposal that needed it is cut.
7. **Draft the design solo.** Architecture, components, data flow, errors, tests. YAGNI.
8. **Write the paragraph** on `PLAN.md` § The sequence: a heading with status and date; *Makes runnable* · *Imports* · *Size*; the decisions with reasons; a Done-when the gate can run. Write it; do not commit it yet.
9. **Self-review and pressure-test.** Placeholders, contradictions, ambiguity (pick one reading). Walk two or three concrete cases end to end: a happy path, an awkward real one (day one, a conflicting source, a stale fact), and one where the design should refuse or degrade. Put the walked examples in the spec.
10. **Present.** Gate on authority first, then the three tests (CLAUDE.md § Decisions, not forks). The flippable list is non-technical forks only and is empty far more often than not. Publish a private review page for the owner carrying everything the decision needs (decision, forks with alternatives, evidence, worked examples), naming the spec by its paragraph heading, republished after any flip. Only when the list is non-empty, ask: "Here are the calls I made; flip any. Good to commit?" An empty list asks nothing: commit the paragraph, say where the page is, and build.

## Exit

**Kill is a valid exit.** No NORTH-STAR trace, changes nothing, or duplicates something that exists: come back with the kill, what to salvage, and one Log line.

Otherwise single-PR work builds from the paragraph. Multi-PR work has the paragraph name the PRs in order, each with its own Done-when, built one at a time, each landing through `/ship` before the next opens. The paragraph is the plan; there is no plan document.
