# Output format for /ix-understand

Produce exactly these sections in this order. All sections are required; write "None identified" if a section has no content.

---

```
# [Target] — Architecture Overview

> **Scope:** [repo | subsystem: <name> | path: <path>]
> **Evidence quality:** [strong | partial | weak] — [one sentence explaining why]
> **Assumption:** [only present if scope was ambiguous — state what you inferred]

## Overview
[One paragraph: what this system/module does, its primary job, why it exists, and who or what uses it.]

## Structure

Key components and their responsibilities:

- **ComponentA** — [role in one line]
- **ComponentB** — [role in one line]
- **ComponentC** — [role in one line]
[3–8 components. Omit noise. Group by layer if there is a clear layering (interface / orchestration / persistence / utilities).]

## Key Flows

Primary execution or data path(s):

1. [Entry point] → [step] → [step] → [outcome]
2. [Second flow if meaningfully different]

[Keep flows as numbered steps. One or two flows is usually enough. Name the entry point explicitly.]

## Dependencies

**Consumes:**
- `dep-name` — [what it's used for]

**Exposes:**
- `interface or API` — [who consumes it, if known]

## Risks & Ambiguity

- [claim or gap] — *inferred* / *uncertain* — [why]
- [component with no graph edges or sparse data] — *uncertain*

[If everything is well-supported, write: "No significant ambiguities. Evidence quality is strong."]

## Next Drill-Downs

Suggested follow-up commands based on what was most central or unclear:

- `/ix-trace <entry-point>` — trace the main execution path in detail
- `/ix-explain <ComponentA>` — deeper look at [its role]
- `/ix-impact <ComponentB>` — assess blast radius before modifying
- `/ix-understand <sub-scope>` — narrow into [specific area]
```

---

## Formatting rules

- Section headers are `##` (h2), component names in lists are `**bold**`
- Use code ticks for symbol names, file paths, and command names
- Bullet lists for Structure and Dependencies; numbered lists for Key Flows
- No trailing summary paragraph — the sections speak for themselves
- Do not add sections beyond those listed above
