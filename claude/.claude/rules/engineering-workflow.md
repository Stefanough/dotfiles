# Engineering Workflow Lessons

Promoted from per-project auto-memory (2026-08-31) so they apply everywhere.

- Subagent dispatches use Opus or below — never let subagents inherit a frontier/Fable session model. Sonnet for runbook work, Opus for judgment calls; frontier verification stays in the main loop.
- Before trusting a new regression test, revert the fix and re-run it — a test that still passes against the broken code is vacuous.
- Branch new, unstacked work from a freshly pulled main — never from whatever branch happens to be checked out.
- When closing out a PR review, re-query unresolved review threads (including isOutdated) — never trust an earlier thread-gathering pass.
- Google Drive doc creation/updates go through rclone (`rclone copyto` with the same name = in-place update); the Drive connector is read/search only. Check for duplicates first; deletions need explicit approval.
- Stacked-PR workflow: land bottom-up; rebase each next branch onto main only after the one below it merges.
