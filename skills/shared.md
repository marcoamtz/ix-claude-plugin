# ix-claude-plugin — Shared Cognitive Model

*This file is referenced by all skills to establish plugin-level graph connectivity.*

Hook library: [hooks/lib/index.sh](../hooks/lib/index.sh) (sources [ix-lib.sh](../hooks/ix-lib.sh) and [ix-errors.sh](../hooks/ix-errors.sh))

---

## Core Principle

Skills are reasoning protocols, not CLI aliases. Each skill:
1. Infers intent from `$ARGUMENTS`
2. Phases queries cheap → expensive
3. Evaluates "can I answer now?" at each phase boundary and stops early if yes
4. Scales depth with risk (low-risk targets → less querying)
5. Reads source code last, at symbol level only

## Token Budget

| Operation | Cap |
|---|---|
| Text search | `--limit 20` |
| Symbol rank | `--top 10`, always `--exclude-path test` |
| Callers / callees | `--limit 15` |
| Dependency tree | `--depth 2` max |
| Code reads | Symbol-level only, max 2 per task |
| Traces | One per investigation |

## Skills in this plugin

- [ix-understand](ix-understand/SKILL.md) — mental model, delegates to ix-system-explorer
- [ix-investigate](ix-investigate/SKILL.md) — symbol deep dive, graph-first
- [ix-impact](ix-impact/SKILL.md) — blast radius, depth scales with risk
- [ix-plan](ix-plan/SKILL.md) — risk-ordered multi-target change plan
- [ix-debug](ix-debug/SKILL.md) — root cause analysis, targeted reads
- [ix-architecture](ix-architecture/SKILL.md) — design health, delegates to ix-architecture-auditor
- [ix-docs](ix-docs/SKILL.md) — narrative-first docs from graph
