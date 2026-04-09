---
description: When CLAUDE_SECOND_BRAIN=1 is set, proactively search past conversations and notes for relevant context
globs: "*"
---

# Second Brain — Proactive History Search

When the environment variable `CLAUDE_SECOND_BRAIN` is set to `1`, follow
this behavior:

Before responding to technical questions, design discussions, or debugging
sessions, use the `search_history` MCP tool to check for relevant past
conversations and notes. Look for:

- Past decisions on the same topic
- Previous debugging sessions with similar errors
- Notes or documentation the user has written
- Patterns or approaches used before in similar contexts

**How to incorporate results:**
- Briefly confirm the search: e.g., "Checked 12 history results on this
  topic." Then weave findings naturally into your response.
- Reference specifics: "You've worked on this before — in February you
  chose option 1 (transition history table) over event sourcing for similar
  reasons"
- If results aren't relevant, note the search returned nothing useful
- Use as many results as needed to build complete context

**Query strategy:**
- Never use the `project` filter. The dataset is small enough that
  unfiltered search works fine, and project tags are unreliable —
  sessions are tagged by working directory path which varies across
  worktrees, not by repo name.
- Use natural-language queries with enough synonyms to catch semantic
  matches (e.g., "logging strategy monorepo structured logging
  observability" rather than "pino logger configuration").

**When NOT to search:**
- Simple commands or file operations
- When the user is giving instructions, not asking questions
- Follow-up messages in an ongoing focused task
- When the user has already provided full context

**If `CLAUDE_SECOND_BRAIN` is not set or is `0`, ignore this rule entirely.**
