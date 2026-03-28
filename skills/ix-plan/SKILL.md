---
name: ix-plan
description: Pre-implementation change plan — given a list of files or symbols to modify, assesses blast radius for each, traces data flows between them, and produces a risk-annotated change plan. Use before any multi-file implementation.
argument-hint: <symbol1> [symbol2] [symbol3] ...
---

If `command -v ix` is unavailable, use Grep + Read to manually assess blast radius for each target.

Parse `$ARGUMENTS` as a space-separated list of targets (files or symbols).

## Step 1 — Impact each target in parallel

For each target in the list, run simultaneously:
```bash
ix impact  <target> --format json
ix callers <target> --format json
```

## Step 2 — Trace data flow between targets

If there are 2+ targets, find how they connect:
```bash
ix trace <target1> --to <target2> --format json
```
Run for the most architecturally significant pair (highest combined impact).

## Step 3 — Check for shared dependents

Find if any third symbol depends on multiple targets (shared blast radius):
```bash
ix depends <highest-risk-target> --depth 2 --format json
```

## Step 4 — Synthesize into a change plan

Output:

```
# Change Plan: <description from arguments>

## Targets & Risk

| Target | Risk | Direct Deps | Key Callers |
|--------|------|-------------|-------------|
| <A>    | high | 12          | X, Y, Z     |
| <B>    | low  | 2           | P           |

## Change Order

Edit in this sequence to minimize breakage:
1. <lowest-risk or most-depended-upon first — explain why>
2. ...

## Data Flow

<A> → <trace path> → <B> (if connected)

## Shared Risk

Symbols affected by changes to both targets: <list>

## Testing Checkpoints

After each change, verify:
- <specific callers or tests to check per target>

## Red Flags

- <any critical/high risk target that needs extra care>
- <any cross-subsystem boundary being crossed>
```
