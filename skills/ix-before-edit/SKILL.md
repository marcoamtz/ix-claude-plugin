---
name: ix-before-edit
description: Pre-edit risk assessment — run before modifying any significant file or symbol. Chains impact + callers + overview to produce a change-safety report. Use this before touching anything with unknown blast radius.
argument-hint: <file or symbol>
---

If `command -v ix` is unavailable, use Grep to find all usages of the target and Read the file to assess what it contains.

Run all three **in parallel**:

```bash
ix impact   $ARGUMENTS --format json
ix callers  $ARGUMENTS --format json
ix overview $ARGUMENTS --format json
```

If `$ARGUMENTS` is a file path, also run:
```bash
ix inventory --path $ARGUMENTS --kind file --format json
```

## Decision framework

After collecting results, produce a **change-safety verdict**:

**SAFE TO CHANGE** — fewer than 3 direct dependents, risk level low/medium, no cross-subsystem callers
> Proceed. Note any callers to verify after the change.

**REVIEW FIRST** — 3–10 direct dependents, or callers span multiple modules
> List the callers by name. Suggest which ones need manual testing after the change.
> Recommend: `ix trace $ARGUMENTS --upstream` to see full propagation.

**HIGH RISK — MAP FULL IMPACT** — 10+ direct dependents, risk level critical/high, or cross-system boundary
> Do not edit without a change plan. Run `/ix-plan $ARGUMENTS` first.
> Show the top impacted members and which subsystems are affected.
> Recommend: `ix depends $ARGUMENTS --depth 3` to see the full blast radius.

## Output format

```
# Pre-Edit Risk Assessment: <target>

Risk level: <critical|high|medium|low>
Direct dependents: <N>
Verdict: <SAFE | REVIEW FIRST | HIGH RISK>

Key callers: <list up to 5 by name, file, kind>
Overview: <what this contains — key definitions>

[If REVIEW FIRST or HIGH RISK:]
Action required: <specific next step>
```
