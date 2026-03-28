---
name: ix-diff
description: Show structural changes between two graph revisions — what entities were added, removed, or modified. Use to understand what changed between sessions, after a big merge, or to audit what a recent edit actually touched.
argument-hint: <fromRev> <toRev> [target]
---

If `command -v ix` is unavailable, fall back to `git diff <fromRev> <toRev>` for source-level changes — note that no structural graph diff will be available.

Parse `$ARGUMENTS`:
- Required: two revision numbers (e.g., `3 18`)
- Optional: a target file or symbol to scope the diff

Run the appropriate command:

**Summary diff (whole repo):**
```bash
ix diff <fromRev> <toRev> --summary --format json
```

**Scoped diff (specific file or symbol):**
```bash
ix diff <fromRev> <toRev> <target> --content --format json
```

**To find current revision:** `ix status` (shows current revision number).

## Output

Present:

**What changed** — entities added, modified, removed between the two revisions

**Structural impact** — if any high-dependency entities changed, flag them:
```bash
ix impact <changed-entity> --format json
```
Run this for any entity with significant changes that appears in the diff.

**Summary line**: "Rev N→M: X entities added, Y modified, Z removed"

## Common use cases

- After `ix map` runs: `ix diff <prev-rev> <current-rev> --summary` to see what the last ingest captured
- After a merge: diff the pre-merge vs post-merge revision to see structural changes
- Debugging: `ix diff 1 <current> <symbol>` to see the full history of a symbol's graph representation
