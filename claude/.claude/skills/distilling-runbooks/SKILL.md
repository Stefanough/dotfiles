---
name: distilling-runbooks
description: Use when planning to parallelize a repetitive engineering effort (migration, upgrade sweep, cleanup campaign, fleet onboarding) across many similar units using cheaper/smaller-model agents — or when a small-model agent produced wrong results despite green checks and a confident self-report.
---

# Distilling Runbooks for Small-Model Execution

## Overview

Distill frontier-model capability into a **process artifact** (an executable runbook) that cheaper models can run unattended across many similar units. Core principle, learned the hard way: **prose rules do not bind small models under momentum — mechanical checks do.** A small model will violate an explicit NEVER while reporting full compliance; it will not fake the output of a grep.

This is TDD applied to process documentation (see superpowers:writing-skills for the underlying RED-GREEN-REFACTOR discipline). This skill adds what that one doesn't cover: structuring documents for *weak executors*, graduated exposure, artifact auditing, and tripwire conversion.

## When to use

- An effort decomposes into many similar, mostly-independent units (services, packages, repos, configs) — the per-unit work is mechanical-with-exceptions
- Unit count × frontier-model cost justifies one-time distillation effort (rule of thumb: ≥5 units)

**Not for**: one-offs (just do them), or work where every unit needs novel judgment that can't be reduced to IF/THEN + STOP.

## The loop

1. **Do the task manually first** (frontier model, 1–2 representative units). Every runbook branch must come from a real surprise, not theory. Record every command, every failure, every judgment call. While there, **inventory the dynamic invocation surfaces** — bins, `exec`/`spawn` with constructed paths, plugins/tools referenced by string name in configs, things loaded by the runtime rather than imported. Static analysis and greps are blind to all of these; the runbook must declare them live *by location* (whole directories/files presumed used), not rely on reference detection.
2. **Baseline the executor (RED)**: give the target small model the *prose* version of the process; have it plan (plan-only, cheap). Record its failures verbatim. The runbook exists to counter these specific failures.
3. **Write the runbook** to the structure contract below, addressing each baseline failure explicitly.
4. **Graduated exposure (GREEN)**: plan-only re-test with the runbook → fix gaps → live run **in an isolated environment** (git worktree / sandbox) where total failure costs only a deleted directory.
5. **Audit the artifact, never the self-report.** Independently verify the completed work product against ground truth: diff vs. baseline, re-run the verification yourself, check every destructive action. Green gates + a confident completion claim can coexist with serious damage — gates can't see deleted operational tooling, removed protected config, or silent semantic changes.
6. **Convert every violation into a tripwire** (REFACTOR): a command inside the runbook with an exact expected output, run before commit. Do not respond to a violation by adding more prose.
7. **Codify every escalation.** STOP rules turn ambiguity into a human decision; each resolved decision is written back as a new sanctioned IF-branch. The runbook monotonically converges toward needing no human.
8. **Right-size the executor empirically.** If a model fails on *discipline* (improvises, "improves" the template, rationalizes around rules), escalate one tier and re-test; don't compensate with more rules. Keep the frontier model as auditor regardless — verification is ~20x cheaper than generation, which is what makes the whole pattern economical.

## Runbook structure contract

A runbook is small-model-executable only if ALL of these hold:

- **Single input parameter**; everything else derived by command
- **Every step**: exact command + expected output + IF-branches for known deviations
- **Decisions as predicates**: greps/scripts with IF/THEN, never "use judgment"
- **MUST/NEVER block up front** — including "use the template verbatim; wanting to change it is a STOP"
- **STOP rules with loop limits**: unmatched output, uncovered finding, Nth edit to the same file, total-loop cap. Frame honestly: *an honest STOP is a successful outcome; improvisation is a failure*
- **Pre-commit tripwires**: self-audit commands with exact expected outputs that mechanically detect rule violations (protected-thing-removed grep → must be empty; allowed-changes diff → must show exactly X)
- **Negative assertions for every removal**: after removing X, mechanically assert X is genuinely *gone* (a require/resolve/lookup of X must FAIL). If the removed thing still works, the sandbox is leaking resources from its host (nested git worktrees resolve the parent repo's node_modules; same class: global caches, ambient env, system services) — and every green gate so far proved nothing
- **Artifact semantic assertions**: gates check exit codes; they do not check that the *artifact* holds its invariants. Identify the campaign's "compiles green but ships broken" modes during the manual phase and encode each as a post-step assertion on the artifact itself (e.g. built output contains no unrewritten path aliases)
- **Exact-identifier predicates**: every grep used as a decision predicate must be delimiter-bounded to the exact identifier — substring matches lie (`dotenv` matches `dotenv-flow`)
- **Self-checkable definition of done**

## Audit protocol (frontier model, per completed run)

1. Diff the artifact against ground truth — read every destructive change
2. Independently verify the executor's claims (re-run tests/checks yourself; "exit 0" is a claim until you've seen it) — and note your re-run inherits the same sandbox leaks the executor's did; prefer assertions that can't be faked by leakage
3. Cross-check removals against external reality the executor can't see (other consumers, deploy config, runtime loading, dynamic invocation)
4. Check artifact semantics, not just gates: inspect the built/produced output for the campaign's known silent-breakage modes
5. **The auditor is bound by the same predicate rules as the executor**: exact-identifier matches only; when your audit disagrees with the executor, resolve against the primary artifact (the actual import line, the actual config), not against your grep — the executor may be right
6. If you audited wrong: retract loudly on the record, then fix the *predicate* that misled you
7. Verdict before merge; violations feed step 6 of the loop

## Common mistakes (all observed live)

| Mistake | Reality |
|-|-|
| Trusting green gates + self-report | Both were clean while live ops tooling was deleted. Audit the diff. |
| Adding prose rules after a violation | The violated rule was already written down. Add a tripwire. |
| Writing the runbook before doing the task manually | Produces confident fiction; branches must come from real surprises. |
| Skipping the baseline | You can't counter failures you haven't observed. |
| Letting the executor "improve" the template | Template fidelity is a STOP condition, not a suggestion. |
| Monitoring execution instead of auditing artifacts | Watching wastes attention; the diff holds the truth. |
| Compensating for a weak model with more rules | Discipline failures are a model-tier signal, not a documentation gap. |
| Trusting gates run inside a leaky sandbox | Nested worktrees resolved the host repo's modules; removals "passed" that would fail any clean checkout. Negative assertions catch this; exit codes don't. |
| Substring predicates | `dotenv` grep matched `dotenv-flow` — sent the *auditor* chasing a correct removal. Bound every predicate to the exact identifier. |
| Equating green build with working artifact | A live compiler transform was removed; build exited 0 while the output shipped broken imports to every consumer. Assert on the artifact. |
| Hardening only after the campaign | Tripwires added mid-wave protected every subsequent unit. Fold lessons in the moment they're learned. |

## Worked example

The knip onboarding campaign (alt-mono, ALL-1623; local skill `knip-onboard` in that repo): Haiku baseline failed 5 ways with the prose playbook; with the runbook it still violated 3 NEVERs while reporting compliance — caught only by diff audit; tripwires added; Sonnet then executed a full unit unattended, hit a novel case, STOPPED correctly, and passed independent audit. ~10 min/unit + 4-command audit.

## Status

Derived from one full live campaign (knip rollout, 2026-06) and refined by its first parallel wave (6 concurrent units): three new silent-failure classes surfaced there — sandbox leakage, substring predicates, green-build/broken-artifact — and are now encoded above. Per the writing-skills Iron Law, the next *new* campaign run with this skill remains its test — capture deviations and refine.
