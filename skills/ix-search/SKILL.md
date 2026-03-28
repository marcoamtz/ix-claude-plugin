---
name: ix-search
description: Search the codebase using Ix Memory graph-aware search combining text search and symbol location
argument-hint: <search term>
---

If `command -v ix` is unavailable, fall back to the Grep and Glob tools instead.

Run in parallel:
1. `ix text $ARGUMENTS --limit 20 --format json`
2. `ix locate $ARGUMENTS --limit 10 --format json` — skip if pattern contains regex metacharacters (`\^$[](){}|*+?`)

Present combined results. Lead with symbol matches from `ix locate` (exact definitions), then text matches from `ix text` (usages). Deduplicate where the same symbol appears in both.

If both return nothing, suggest `/ix-understand $ARGUMENTS` in case it's a subsystem name.
