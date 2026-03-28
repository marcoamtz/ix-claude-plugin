---
name: ix-investigate
description: Full graph investigation of a symbol — chains explain → trace → depends → callers → impact into a complete picture. Use when you need to deeply understand a component before modifying it or explaining it to someone.
argument-hint: <symbol>
---

If `command -v ix` is unavailable, use Grep + Read to gather what you can about the symbol's definition, callers, and usages.

Run all five queries **in parallel** using the Bash tool:

```bash
ix explain $ARGUMENTS --format json
ix trace   $ARGUMENTS --format json
ix depends $ARGUMENTS --depth 2 --format json
ix callers $ARGUMENTS --format json
ix impact  $ARGUMENTS --format json
```

If `$ARGUMENTS` is ambiguous, first run `ix locate $ARGUMENTS --format json`, pick the best match, and re-run with `--path <path>` or `--pick <n>` to scope all five queries.

## Output

Synthesize into a single structured report:

**Identity** — what it is, where it lives, what kind of entity (from `ix explain`)

**Role** — the inferred role (orchestrator / helper / boundary / utility / etc.) and importance

**Execution flow** — what it calls downstream (from `ix trace --downstream`); what calls it upstream (from `ix callers` + `ix trace --upstream`)

**Dependency tree** — key upstream dependents at depth 2 (from `ix depends`): who would break if this changed

**Risk profile** — risk level, summary, and hot spots (from `ix impact`); include the `nextStep` suggestion from ix

**Recommended next actions** based on what was found:
- If high-risk: `/ix-before-edit $ARGUMENTS` before any changes
- If complex trace: `/ix-trace $ARGUMENTS --to <specific-target>` to narrow the path
- If god-module: `/ix-smells` to see if this is flagged
