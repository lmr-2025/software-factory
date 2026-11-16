# North star

<!-- The page every piece of work is held against. Keep it short enough to read
before every session. A session names, before it starts, the numbered tests its
work moves toward and the ones it must not break. Replace the examples below. -->

## The bet

One paragraph: what this is for and who it is for, in words a stranger would understand.

## How to use it

Before any work, write at the top of the run's checklist: *moves toward* test N, *must not break* tests M and K. A design that traces to no test is a kill signal, not a smaller project. Before merging, run the tests.

## The tests

Each test is something a person could check by hand, phrased so the answer is yes or no.

1. **A new user gets value on day one.** Example: a Northwind employee installs it, points it at their repository, and gets a useful answer within ten minutes, with no setup call.
2. **Every claim shows its source.** Example: any statement the system makes links to the file and line it came from.
3. **Nothing leaves without the owner's yes.** Example: no code path sends repository content to a third party unless a setting the owner turned on says so.

## Done means

What "finished" looks like for the current stage, as a short list of lines from the tests above that must read yes.
