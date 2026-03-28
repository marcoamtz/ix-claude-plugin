---
name: ix-read
description: Read the source of a specific symbol (function, class, method) — resolves to exact file:lines and returns just that symbol's code. Replaces Read tool + manual line hunting. Far cheaper than reading entire files.
argument-hint: <symbol>
---

If `command -v ix` is unavailable, use Grep to locate the symbol then Read the relevant lines from the file.

Run:
```bash
ix read $ARGUMENTS --format json
```

Resolution order (ix handles automatically):
1. Exact file path → returns whole file
2. `file.ts:10-50` → returns that line range
3. Unique filename → returns file
4. Unique symbol name → returns just that symbol's source

If ambiguous, ix will return candidates. Use `--path <path>` or `--kind <kind>` to disambiguate, or `--pick N` to select.

## When to use this vs Read tool

| Scenario | Use |
|----------|-----|
| Need one function's implementation | `ix read <function>` — returns ~10-50 lines |
| Need to understand a class's structure | `ix overview <class>` first, then `ix read <class>` |
| Need full file context | `Read` tool |
| Checking a specific line range | `ix read file.ts:start-end` |

## Output

Present the source with:
- The resolved file path and line range
- The raw source (from the `content` field in JSON output)
- A note if the file is stale (changed since last `ix map`)

Do not add explanation unless asked — the source speaks for itself.
