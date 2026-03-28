---
name: ix-smells
description: Detect code smells and structural issues in the codebase using Ix Memory
argument-hint: [path or module]
---

If `command -v ix` is unavailable, say so — this skill requires an ix graph. Direct the user to install ix and run `ix map` to build the graph first.

If `$ARGUMENTS` is provided: `ix smells --path $ARGUMENTS --format json`
Otherwise: `ix smells --format json`

Present findings grouped by severity (high → medium → low). For each issue: what the smell is, which file/symbol is affected, and why it matters.

For high-severity items, suggest `/ix-impact <symbol>` to understand blast radius before fixing.
