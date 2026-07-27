# Comments — Default to Zero

Code must be self-documenting via names and structure. Comments are a last resort, not a default.

When tempted to write a comment, ask: *would a careful reader still misunderstand this after reading the code (and tests)?* If no, don't write it.

## Antipatterns to actively avoid

- **Justifying inline values.** `const TTL = 20 * 60;` is enough. Don't write a paragraph explaining why 20 minutes — that's commit-message and PR-body content. It rots the moment the next change makes it stale.
- **Documenting negative space.** Don't write `// intentionally no Y because X throws`. A test or a reviewer reading the call site can derive this.
- **Referencing tickets or prior PRs.** `// ALL-123 follow-up will...` and `// See #4567` belong in the PR description, not the source. They rot.
- **JSDoc on every export.** If `withTiming(args, fn): Promise<T>` is type-checked, the name + types carry all the info. Skip the JSDoc unless behavior is genuinely surprising.
- **Echoing what the code does.** `// Check Redis first` above `await redis.get(key)` is noise.
- **Explaining the obvious to "help future readers".** Future readers can read code. They cannot un-rot a stale comment.

## When a comment IS warranted (rare)

- A hidden constraint with no representation in code (regulator-imposed ordering, an invariant the type system can't express).
- A subtle invariant that a refactor could easily break and that no test catches.
- A workaround for a *specific*, *named* bug or third-party quirk.
- Behavior that would genuinely surprise a careful reader.

Even then: one short line, not a paragraph. If unsure, don't write the comment. Names and types should do the work. Rationale belongs in `git log` and the PR description.
