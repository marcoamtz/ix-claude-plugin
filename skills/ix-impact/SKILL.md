---
name: ix-impact
description: Analyze the blast radius and downstream impact of changing a symbol, file, or module using Ix Memory
argument-hint: <symbol or file>
---

If `command -v ix` is unavailable, use Grep to find all usages of the target and estimate impact from that.

Run `ix impact $ARGUMENTS --format json`.

If impact returns nothing or is ambiguous, run `ix locate $ARGUMENTS --format json` to resolve the symbol, then retry with `--path` or `--pick`.

## Decision framework after getting results

**Risk level: critical or high AND direct dependents > 5:**
Also run in parallel:
```bash
ix depends  $ARGUMENTS --depth 2 --format json
ix callers  $ARGUMENTS --format json
```
Then suggest `/ix-plan $ARGUMENTS` before making changes.

**Risk level: medium, OR direct dependents 2–5:**
Note the key callers by name. Suggest verifying those callers after the change.

**Risk level: low, OR direct dependents < 2:**
Safe to proceed. Note any callers for completeness.

## Output structure

```
Risk level: <critical|high|medium|low>
Summary: <riskSummary from ix>
Direct dependents: <N> | Transitive (depth 2): <M>
At-risk behavior: <list from atRiskBehavior>

[If high/critical — also show:]
Key callers: <top 5 from callers query>
Propagation: <which subsystems are affected>

Verdict: <SAFE | REVIEW FIRST | HIGH RISK — see /ix-plan>
Next step: <nextStep from ix output>
```

Suggest `/ix-trace $ARGUMENTS` to understand the execution path, or `/ix-before-edit $ARGUMENTS` for a full pre-edit safety check.
