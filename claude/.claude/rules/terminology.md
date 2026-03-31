---
description: When the user asks for a definition, clarification, or standardization of terminology
---

# Terminology Definitions

When the user asks you to define, clarify, or standardize a term — including
phrases like "what is X", "what does X mean", "define X", "explain the term X",
or correcting jargon — follow this process:

1. **Historical context first.** Start with where the term comes from — its
   etymology or the problem that motivated its creation. Follow the project's
   notes style preference: full context over jumping straight to usage.

2. **Concise definition.** Give a clear, direct definition in 2-4 sentences.

3. **Primary sources.** Include one or more authoritative sources. Prefer in
   this order:
   - Original paper, RFC, or specification that introduced the term
   - Official documentation from the technology that defines it
   - Authoritative reference (e.g., Wikipedia for well-established CS terms)
   
   Use WebSearch or WebFetch to find sources when not confident. Never
   fabricate a citation. If no authoritative source exists, say so.

4. **Context of use.** If the term came up in the current conversation, briefly
   connect the definition back to the specific context where it was raised.

Format example:

> **Idempotent** — from Latin *idem* ("the same") + *potent* ("having power").
> In mathematics, an operation that produces the same result when applied
> multiple times: f(f(x)) = f(x). Adopted into computing to describe
> operations that can be safely retried — making the same API call twice
> produces the same state as making it once.
>
> Sources:
> - [RFC 7231 §4.2.2 — Idempotent Methods](https://www.rfc-editor.org/rfc/rfc7231#section-4.2.2)
> - [HTTP Semantics (RFC 9110) §9.2.2](https://www.rfc-editor.org/rfc/rfc9110#section-9.2.2)
