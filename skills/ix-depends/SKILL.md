---
name: ix-depends
description: Show the full upstream dependency tree for a symbol — who depends on it, and who depends on those dependents. Use to understand blast radius before a change, or to find all consumers of an API.
argument-hint: <symbol> [--depth N]
---

If `command -v ix` is unavailable, use Grep to find all usages of the symbol as a fallback.

Parse `$ARGUMENTS`:
- If it contains `--depth N`, extract the depth value
- Otherwise default to depth 2

Run:
```bash
ix depends <symbol> --depth <N> --format json
```

If the symbol is ambiguous, first run `ix locate <symbol> --format json` to resolve it.

## Output

Present the dependency tree hierarchically:

```
<symbol> (<kind>, <file>)
├── <direct dependent 1> (<kind>) — <file>
│   ├── <transitive dependent> (<kind>)
│   └── ...
├── <direct dependent 2> (<kind>) — <file>
└── ...

Total: N direct, M transitive dependents
```

Then add:
- **Cross-subsystem dependents** — flag any dependents that live in a different subsystem (these are higher-risk for breaking changes)
- **Test-only dependents** — note if most callers are tests (lower risk for implementation changes)
- **Suggested next step**: if N > 10, suggest `/ix-plan <symbol>` before making changes
