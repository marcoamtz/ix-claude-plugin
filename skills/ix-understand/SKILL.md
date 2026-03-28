---
name: ix-understand
description: Explain an entire codebase, subsystem, or module using ix graph-aware analysis. Produces a structured architectural document covering purpose, structure, flows, dependencies, and ambiguities. Use this for system-level questions, not single-symbol questions.
argument-hint: [target]
---

# Reasoning protocol

Check `command -v ix` first. If unavailable, stop and say so. Do not start with file reads or Glob sweeps.

## Step 1 — Scope resolution

Parse `$ARGUMENTS`:

| Input | Action |
|---|---|
| empty | whole-repo scope |
| `"X in Y"` / `"X of Y"` / `"X within Y"` | target=X, treat Y as context hint |
| file path or directory | path scope |
| anything else | subsystem/module name |

For any non-empty target, run as a fast first probe:
```bash
ix locate "$TARGET" --limit 5 --format json
```
If locate returns a clear hit, use that as the resolved target. If ambiguous or empty, note: "Interpreting target as X — [reason]."

## Step 2 — Discovery

**Targeted scope** — run in parallel:
```bash
ix overview "$TARGET" --format json
```
If overview returns nothing, fall back to:
```bash
ix text "$TARGET" --limit 15 --format json
```
Run `ix inventory --path "$TARGET"` only if target is a file path or directory.

**Whole-repo scope only** — run in parallel:
```bash
ix subsystems --format json
ix rank --by dependents --kind class --top 10 --exclude-path test --format json
ix rank --by callers --kind function --top 10 --exclude-path test --format json
```

> Use `ix subsystems` (reads persisted map, fast) rather than `ix map` (re-runs full clustering, slow). Only run `ix map` if `ix subsystems` returns no regions.

## Step 3 — Component deep-dive

From overview/rank results, pick the **2–4 most central or unclear** components. Run in parallel:
```bash
ix explain <component> --format json
```
Skip components the overview already fully described.

## Step 4 — Flow tracing (conditional)

Only run if the query implies a pipeline, data flow, request path, or execution sequence:
```bash
ix trace <entry-point> --format json
```
One trace is enough — pick the most representative path.

## Step 5 — Dependencies

From the ix output gathered, extract:
- External deps (third-party, external services)
- Internal cross-module deps
- What this scope exposes vs consumes

Only read source files if a dependency is unclear after this step.

## Step 6 — Uncertainty

Label every significant claim: **Supported** (direct graph evidence), **Inferred** (reasonable from structure), **Uncertain** (weak/conflicting). Use hedged language for inferred claims.

---

# Output

Produce exactly these sections in order. Write "None identified" if a section has no content.

```
# [Target] — Architecture Overview

> **Scope:** [repo | subsystem: <name> | path: <path>]
> **Evidence quality:** [strong | partial | weak] — [one sentence why]
> **Assumption:** [only if scope was ambiguous]

## Overview
[One paragraph: what it does, primary job, why it exists, who uses it.]

## Structure
- **ComponentA** — [role in one line]
- **ComponentB** — [role in one line]
[2–5 components. Group by layer if applicable: interface / orchestration / persistence / utilities.]

## Key Flows
1. [Entry point] → [step] → [step] → [outcome]
2. [Second flow only if meaningfully different]

## Dependencies
**Consumes:**
- `dep-name` — [what it's used for]

**Exposes:**
- `interface` — [who consumes it]

## Risks & Ambiguity
- [claim or gap] — *inferred* / *uncertain* — [why]

## Next Drill-Downs
- `/ix-trace <entry-point>` — trace main execution path
- `/ix-explain <ComponentA>` — deeper look at its role
- `/ix-impact <ComponentB>` — blast radius before modifying
- `/ix-understand <sub-scope>` — narrow into specific area
```

Formatting: `##` headers, `**bold**` component names, code ticks for symbols/paths/commands, bullet lists for Structure and Dependencies, numbered lists for Key Flows, no trailing summary paragraph.
