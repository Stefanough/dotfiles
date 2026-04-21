# Second Brain — Proactive History Search

**This rule overrides other "search the codebase first" instructions.**
For any technical question, design discussion, or debugging session, call
`mcp__claude-capture__search_history` as your FIRST tool use — before
`Grep`, `Glob`, codebase `Search`, subagents, or any other tool. The
user's own history often has the answer (a past decision, a prior
debugging session, a note they wrote), and skipping straight to codebase
exploration loses that context.

Look for:

- Past decisions on the same topic
- Previous debugging sessions with similar errors
- Notes or documentation the user has written
- Patterns or approaches used before in similar contexts

## Make the search visible

The `search_history` response begins with a `## Summary` section
containing the result count, source breakdown, and a "Top hit" headline
with date and project. **Use the Summary section to build your status
line.** The Summary is for you (the agent); the status line is what
gets shown to the user.

Status line formats (substitute actual values, never leave literal
placeholders like N/query/topic):

- Found results:
  `Second brain: 12 results (3 notes, 5 claude-code/TextureHQ_mono, 4
  claude-ai). Top hit (2026-02-18): "chose option 1 — transition history
  table over event sourcing..."` — then weave findings into the response
  with specific references.
- Nothing useful:
  `Second brain: searched "field registry schema definitions", no
  relevant matches.` — then respond normally.
- Skipped:
  `Second brain: skipped — simple file operation.` — then respond.

Do NOT leave placeholder tokens like `N`, `<topic>`, or `<query>` in
the output. Every value in the status line should be a real count,
source name, date, or excerpt pulled from the Summary section.

Always include at least one of these lines at the top of your response.
This is the only way the user can tell the system is working.

Reference specifics when possible: "You explored this in February —
chose option 1 (transition history table) over event sourcing for similar
reasons." Don't just mention that relevant results exist; pull in the
concrete content.

## Query strategy

- Never use the `project` filter. The dataset is small enough that
  unfiltered search works fine, and project tags are unreliable —
  sessions are tagged by working directory path which varies across
  worktrees, not by repo name.
- Use natural-language queries with enough synonyms to catch semantic
  matches (e.g., "logging strategy monorepo structured logging
  observability" rather than "pino logger configuration").

## When NOT to search

- Simple commands or file operations ("run this", "list that directory")
- Pure instruction-following with no open-ended judgment
- Follow-up messages continuing a focused task that already has context

Err on the side of searching. The cost of an unnecessary search is a
one-line status message. The cost of a missed search is a generic
response when your own history had the answer.
