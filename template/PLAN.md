# Plan

<!-- The program's state, and the only spec. One paragraph per piece of work;
the paragraph IS the spec, and its tracker ticket is one line pointing here.
There is no separate specs folder and no plan document. -->

## The question

The one question every returned diff is read against. Example: *does this make NORTH-STAR test 1 read yes for a Northwind employee on day one?*

## The sequence

Paragraphs in the order they should be built. A session opens this section, works top-down, and says so when it is dry.

### Example: one-command install (open, 2026-01-15)

*Makes runnable:* NORTH-STAR test 1 · *Imports:* nothing · *Size:* about 200 lines.

**Decided.** The installer is one shell script with no dependencies beyond git and curl, because test 1 says "no setup call" and every extra dependency is a call. It refuses to overwrite an existing config rather than merging, because a merge that guesses wrong is worse than a clear error.

**Done when.** `scripts/install.sh` on a clean machine prints a working URL in under ten minutes, and a test in the gate runs it in a container.

## Open forks

Forks that only the owner can settle, each with a recommendation. Normally empty. A fork is never a ticket or a label; the ticket says *fork open on the paragraph*.

## Log

One line per closed or killed paragraph, newest first: the date, what happened, the PR.
