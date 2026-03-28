---
name: ix-subsystems
description: Explore the architectural map — visualize subsystems, understand cohesion/coupling, get plain-English explanations of what each region does. Use for architecture questions and system orientation.
argument-hint: [target]
---

If `command -v ix` is unavailable, say so — this skill requires an ix graph. Direct the user to install ix and run `ix map` to build the graph first.

## With no argument — full architecture overview

Run in parallel:
```bash
ix subsystems --format json
ix subsystems --graph
```

Present:
- System hierarchy (systems → subsystems → modules) with file counts
- Cohesion and coupling scores for each region
- Regions with low confidence (fuzzy boundaries) — flag these as uncertain
- Top 3 highest-coupling modules (potential design smell)

## With a target — scoped deep-dive

Run in parallel:
```bash
ix subsystems $ARGUMENTS --format json
ix subsystems $ARGUMENTS --explain
ix subsystems $ARGUMENTS --graph
```

If `ix subsystems $ARGUMENTS` is ambiguous, try `--pick 1` through `--pick 3` and present the candidates.

Present:
- **Plain English explanation** (from `--explain`) — what this subsystem does, its role in the system
- **Structure** — child regions, file count, dominant signals (calls/imports/path)
- **Health metrics** — cohesion score, external coupling, boundary ratio
- **Cross-cutting concern?** — if `crosscut_score > 0.1`, flag it
- **Suggested drill-down**: `ix rank --by dependents --kind class --path <subsystem-path>` to find its most important components

## Interpreting the metrics

- **cohesion** — how tightly files within the region call each other (higher = more cohesive)
- **external_coupling** — how much this region calls outside itself (lower = more self-contained)
- **boundary_ratio** — ratio of internal to external calls; < 1.0 means more outbound than inbound
- **crosscut_score** — how much this region spans multiple other subsystems; > 0.1 is a smell
- **confidence** — how confident ix is in the boundary detection; < 0.6 = fuzzy/uncertain
