---
name: ix-explain
description: Explain a symbol, function, class, or module using Ix Memory graph-aware analysis
argument-hint: <symbol>
---

For system-level questions ("how does [module/service/subsystem] work", "explain the architecture of X") use `/ix-understand` instead — this skill is for single symbols only.

Run `ix explain $ARGUMENTS --format json` using the Bash tool.

Present a clear explanation covering: what the symbol does, its purpose in the system, inputs and outputs, and any notable behaviors or side effects. If ix returns no result, fall back to `ix locate $ARGUMENTS --format json` to find it, then read the source directly.
