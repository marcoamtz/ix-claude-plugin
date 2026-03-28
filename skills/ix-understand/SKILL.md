---
name: ix-understand
description: Explain an entire codebase, subsystem, or module using ix graph-aware analysis. Produces a structured architectural document covering purpose, structure, flows, dependencies, and ambiguities. Use this for system-level questions, not single-symbol questions.
argument-hint: [target]
---

# When to use

Trigger on:
- `/ix-understand`, `/ix-understand <name>`, `/ix-understand <path>`
- "how does [system/module/service] work"
- "explain the architecture of [thing]"
- "what is this codebase / repo about"
- "walk me through [subsystem]"
- "give me an overview of [module]"

Do NOT use for single-symbol questions (a function, class, variable) — use `/ix-explain` instead.

---

# Reasoning protocol

Follow these steps in order. Do not skip ahead to reading files.

## Step 1 — Scope resolution

Parse `$ARGUMENTS`:

| Input | Scope |
|---|---|
| empty | whole repo — top-level architecture |
| name matching a subsystem or module | subsystem scope |
| file path or directory | path scope |
| ambiguous | pick best match, state assumption explicitly |

If the target is ambiguous, run `ix text "$ARGUMENTS" --limit 10 --format json` to locate it, pick the strongest match, and say: "Interpreting target as X — [reason]."

## Step 2 — Architecture-first discovery

Run these **before reading any files**:

```bash
ix rank --format json
```

If `$ARGUMENTS` is non-empty, also run in parallel:

```bash
ix overview "$ARGUMENTS" --format json
ix inventory --path "$ARGUMENTS" --format json
```

If `ix overview` returns nothing, fall back to:

```bash
ix text "$ARGUMENTS" --limit 20 --format json
```

For whole-repo scope, also run:

```bash
ix map --format json
```

## Step 3 — Component deep-dive

From `ix rank` and `ix overview` results, identify the 3–8 most central components. For each, run:

```bash
ix explain <component> --format json
```

Run these in parallel. Skip any that ix rank already fully described.

## Step 4 — Flow tracing

Identify the primary entry point or orchestrating component. Trace it:

```bash
ix trace <entry-point> --format json
```

If there is an obvious data flow (ingestion pipeline, request handler, event loop), trace that specifically. One trace is enough — pick the most representative path.

## Step 5 — Dependency extraction

From the ix output gathered so far, extract:
- External dependencies (third-party libraries, external services)
- Internal cross-module dependencies
- What this scope exposes vs what it consumes

Only read source files if a critical dependency is unclear after this step.

## Step 6 — Uncertainty classification

Label every significant claim:
- **Supported** — direct graph evidence (ix returned it explicitly)
- **Inferred** — reasonable conclusion from structure, not explicitly stated
- **Uncertain** — weak or conflicting evidence; flag it

Use hedged language for inferred claims: "the graph suggests…", "likely…", "unclear from available data". Do not assert what the graph does not support.

---

# Output

Use the template in `references/output-format.md`. Produce all sections. Keep structure sections as bullet lists. Reserve prose for the Overview paragraph and flow descriptions.

---

# Constraints

- Check `command -v ix` first. If ix is unavailable, stop and say so.
- Do not start with file reads or Glob sweeps.
- Only read source files to confirm a specific detail after ix has established the structure.
- If ix data is thin (new or unindexed repo), say so and note which claims are based on raw file fallbacks.
- Prefer parallel ix queries to reduce latency on large repos.
