---
name: ix-explain
description: Explain a symbol, function, class, or module using Ix Memory graph-aware analysis
argument-hint: <symbol>
---

If `command -v ix` is unavailable, use Grep to locate the symbol then Read the source directly.

For system-level questions ("how does [module/service/subsystem] work") use `/ix-understand` instead — this skill is for single symbols only.

If `$ARGUMENTS` is a file path, run `ix inventory --path $ARGUMENTS --format json` to list its entities, then explain the most important ones.

Otherwise run `ix explain $ARGUMENTS --format json`.

If ix returns nothing, fall back to `ix locate $ARGUMENTS --format json` to find the symbol, then read the source directly.

Present: what the symbol does, its purpose in the system, inputs/outputs, and notable behaviors or side effects.

Suggest `/ix-trace $ARGUMENTS` if the caller would benefit from seeing execution flow, or `/ix-impact $ARGUMENTS` before making changes.
