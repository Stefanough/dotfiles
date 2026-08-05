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

1. **Do the task manually first** (frontier model, 1–2 representative units). Every runbook branch must come from a real surprise, not theory. Record every command, every failure, every judgment call. While there, **inventory the dynamic invocation surfaces** — bins, `exec`/`spawn` with constructed paths, plugins/tools referenced by string name in configs, things loaded by the runtime rather than imported. Static analysis and greps are blind to all of these; the runbook must declare them live *by location* (whole directories/files presumed used), not rely on reference detection. Also inventory the **shared execution surfaces** that encode the invariant your campaign changes — CI cache logic, docker COPY lists, composite actions, runtime loaders. Those break only on the first unit's PR (unit-local gates can't see them): budget the first 1–2 PRs as platform-fix vehicles, and convert each landed fix into a runbook preflight assert (grep the shared file; 0 matches = STOP, rebase). For a subsystem swap, write the full old-knob → new-knob equivalence table up front, including "no equivalent — document" rows; every knob mapped reactively becomes a reviewer finding later.
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
- **Cache-restoration audit**: caches are time machines — any restore path whose key omits a relocated artifact's true inputs resurrects the old world (or omits the artifact) on hit. Regeneration must run post-restore, or the key must include the artifact's inputs
- **Invocation-context fidelity**: validate every command under the exact context CI/production uses — yarn-run vs npx vs script file location can silently change module resolution and compiler config; a lookalike invocation that passes proves nothing
- **Bot dispositions**: harvest review-bot findings from the reference PRs into sanctioned apply/reject-with-rationale entries. Bots are advisory inputs to predicates, not authorities — an executor applying an inapplicable suggestion to be agreeable is a failure, and without canned dispositions the fleet re-litigates every finding N times
- **Shepherd to green, bounded**: don't end the runbook at "PR opened" — the PR gauntlet is recurring work too. Known CI-failure signatures and bot dispositions become IF-branches with a fix-cycle cap; anything novel is a STOP. Coverage grows monotonically like the rest of the runbook
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
| Trusting a mocked suite as the canary | A fully-mocked suite (161/161 green) sailed through a module-load crash that an honest suite caught instantly. Record each unit's test honesty at baseline; gate template changes on the least-mocked reference unit. |
| Cache keys from the old world | A node_modules cache hit skipped postinstall; the relocated artifact never regenerated; tsc failed only in CI, only on pushes that didn't touch the lockfile. |
| Mapping swapped-subsystem knobs reactively | Three successive review-bot findings on the same config block; one upfront equivalence table would have been zero. |
| First-unit failures read as unit bugs | All three CI failures on the reference PRs were shared-infra assumptions (docker COPY list, loader behavior, cache logic) — platform fixes, not unit fixes. Expect this; assert the fixes onto later units' bases. |
| Proximity predicates with magic distances | A `-B5` grep window broke when its template grew three lines; the executor STOPped on a false negative (correctly). Anchor predicates to template structure — the property inside the call — not to line offsets. Re-validate every proximity predicate whenever a template changes. |
| Accepting cross-campaign attribution unverified | "Those failures are the other campaign's" was only half right: of six failures, three were the other campaign, two were network flakes (retry), one was pre-existing main breakage — plausibly the *other* campaign's collateral. Parallel campaigns sharing CI surfaces display each other's failures; attribute each one before ignoring any. |

## Worked example

The knip onboarding campaign (alt-mono, ALL-1623; local skill `knip-onboard` in that repo): Haiku baseline failed 5 ways with the prose playbook; with the runbook it still violated 3 NEVERs while reporting compliance — caught only by diff audit; tripwires added; Sonnet then executed a full unit unattended, hit a novel case, STOPPED correctly, and passed independent audit. ~10 min/unit + 4-command audit.

## Status

Derived from one full live campaign (knip rollout, 2026-06) and refined by its first parallel wave (6 concurrent units): three new silent-failure classes surfaced there — sandbox leakage, substring predicates, green-build/broken-artifact — and are now encoded above. Further refined by the Prisma 7 service campaign (quat mono, ALL-1750, 2026-06): shared-surface inventory, cache time machines, invocation-context fidelity, mocked-canary blindness, knob-equivalence tables, bot dispositions, and bounded PR shepherding all came from its reference-PR phase. Per the writing-skills Iron Law, the next *new* campaign run with this skill remains its test — capture deviations and refine.
