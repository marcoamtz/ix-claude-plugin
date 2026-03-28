# ix-claude-plugin

A Claude Code plugin that makes Claude always use [Ix Memory](https://github.com/ix-infrastructure/IX-Memory) for codebase understanding — injecting session context on every prompt, intercepting all searches and file reads with graph-aware queries, and keeping the Ix graph current as Claude edits.

## Installation

```
/plugin marketplace add ix-infrastructure/ix-claude-plugin
/plugin install @ix-memory/
```

Restart Claude Code after installing.

## Requirements

- [Ix Memory](https://github.com/ix-infrastructure/IX-Memory) installed and running (`ix status` returns ok)
- `jq` in PATH
- `ripgrep` (`rg`) in PATH

```bash
# Ubuntu/Debian
sudo apt install jq ripgrep

# macOS
brew install jq ripgrep
```

## What It Does

| Trigger | Hook | Effect |
|---------|------|--------|
| User sends any prompt | `UserPromptSubmit` → `ix-briefing.sh` | Injects session briefing (goals, bugs, decisions) once per 10 min |
| Claude runs `Grep` or `Glob` | `PreToolUse` → `ix-intercept.sh` | Front-runs with `ix text` + `ix locate`/`ix inventory` |
| Claude runs `Read` | `PreToolUse` → `ix-read.sh` | Front-runs with `ix inventory` + `ix overview` for the file |
| Claude runs `Bash` with grep/rg | `PreToolUse` → `ix-bash.sh` | Extracts pattern, front-runs with `ix text` + `ix locate` |
| Claude edits a file | `PostToolUse` → `ix-ingest.sh` (async) | Ingests changed file into the Ix graph |
| Claude finishes responding | `Stop` → `ix-map.sh` (async) | Runs `ix map` to refresh the full architectural graph |

All hooks bail silently if `ix` is not in PATH or the backend is unreachable.

## Uninstall

```
/plugin uninstall ix-memory
```
