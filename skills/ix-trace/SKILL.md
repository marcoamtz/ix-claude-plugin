---
name: ix-trace
description: Trace the execution flow or call chain for a symbol using Ix Memory
argument-hint: <symbol> [--to <target>] [--upstream|--downstream]
---

If `command -v ix` is unavailable, use Grep + Read to manually trace callers and callees.

Parse `$ARGUMENTS`:
- `<symbol>` — trace full call chain (both directions)
- `<symbol> --to <target>` — find the path between two specific symbols
- `<symbol> --upstream` — show who calls/imports this (callers chain)
- `<symbol> --downstream` — show what this calls/imports (outward flow)

If ambiguous, first run `ix locate $ARGUMENTS --format json` to resolve it.

## Commands

**Full trace:**
```bash
ix trace $ARGUMENTS --format json
```

**Path between two symbols** (use when asked "how does A reach B"):
```bash
ix trace <symbol> --to <target> --format json
```

**Upstream only** (who calls this — useful for impact analysis):
```bash
ix trace $ARGUMENTS --upstream --format json
ix depends $ARGUMENTS --depth 2 --format json
```
Run both in parallel for upstream questions.

## Output

Present as a readable flow:

```
<symbol> (<kind>, <file>)

Downstream (what it calls):
  → <callee1> (<kind>) → <callee2> → ... [cycles marked with ↺]

Upstream (what calls it):
  ← <caller1> (<kind>, <file>)
  ← <caller2> (<kind>, <file>)
```

For `--to` traces, show the specific path:
```
<A> → <intermediate1> → <intermediate2> → <B>
Path length: N hops
```

Flag:
- **Cycles** (↺) — recursive or circular calls
- **Cross-subsystem edges** — calls that cross architectural boundaries
- **High-fan-out nodes** — anything calling 10+ things (potential god function)

Suggest `/ix-impact $ARGUMENTS` if upstream callers are numerous, or `/ix-investigate $ARGUMENTS` for a full picture.
