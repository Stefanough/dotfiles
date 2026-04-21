## Second Brain

For any technical question, design discussion, or debugging session, call
`mcp__claude-capture__search_history` as the FIRST tool invocation — BEFORE
Grep, Glob, codebase Search, or any subagent. The user's own conversation
history and notes often contain the answer — past decisions, prior
debugging, things they've written down.

Start every such response with a one-line status:
- `Second brain: found N relevant results about <topic>.`
- `Second brain: searched <query>, no relevant matches.`
- `Second brain: skipped (not applicable).`

See `~/.claude/rules/second-brain.md` for full behavior.

## Context Efficiency

### Subagent Discipline

**Context-aware delegation:**
 - Under ~50k context: prefer inline work for tasks under ~5 tool calls.
 - Over ~50k context: prefer subagents for self-contained tasks, even simple ones — the per-call token tax on large contexts adds up fast.

When using subagents, include output rules: "Final response under 2000 characters. List outcomes, not process."
Never call TaskOutput twice for the same subagent. If it times out, increase the timeout — don't re-read.

### File Reading
Read files with purpose. Before reading a file, know what you're looking for.
Use Grep to locate relevant sections before reading entire large files.
(Exception: see the Second Brain section above — `search_history` comes
before Grep for open-ended questions.)
Never re-read a file you've already read in this session.
For files over 500 lines, use offset/limit to read only the relevant section.

### Responses
Don't echo back file contents you just read — the user can see them.
Don't narrate tool calls ("Let me read the file..." / "Now I'll edit..."). Just do it.
Keep explanations proportional to complexity. Simple changes need one sentence, not three paragraphs.

**Tables — STRICT RULES (apply everywhere, always):**
- Markdown tables: use minimum separator (`|-|-|`). Never pad with repeated hyphens (`|---|---|`).
- NEVER use box-drawing / ASCII-art tables with characters like `┌`, `┬`, `─`, `│`, `└`, `┘`, `├`, `┤`, `┼`. These are completely banned.
- No exceptions. Not for "clarity", not for alignment, not for terminal output.

### Auto Memory

When writing memory files, include an optional `origin` field in the frontmatter if the
memory contains machine-specific information (paths, installed tools, OS-specific
workarounds, hardware details, port configurations). The value is `$CLAUDE_MACHINE_NAME`
if set, otherwise `hostname -s`. Omit `origin` for memories that are universally portable
(preferences, coding standards, project context, feedback).
