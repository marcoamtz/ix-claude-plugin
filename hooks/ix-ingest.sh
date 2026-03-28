#!/usr/bin/env bash
# ix-ingest.sh — PostToolUse hook for Write, Edit, MultiEdit, NotebookEdit
#
# Fires after Claude modifies a file. Runs ix map on the changed file to keep
# the graph current so the next query reflects the current code state.
#
# Runs async (does not block Claude's response).

set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
[ -z "$FILE_PATH" ] && exit 0

# Bail silently if ix is not in PATH
command -v ix >/dev/null 2>&1 || exit 0

# ── Health check (30s TTL cache) ─────────────────────────────────────────────
IX_HEALTH_CACHE="${TMPDIR:-/tmp}/ix-healthy"
_now=$(date +%s)
_cache_ok=0
if [ -f "$IX_HEALTH_CACHE" ]; then
  _cached=$(cat "$IX_HEALTH_CACHE" 2>/dev/null || echo 0)
  (( (_now - _cached) < 30 )) && _cache_ok=1
fi
if [ "$_cache_ok" -eq 0 ]; then
  ix status >/dev/null 2>&1 || exit 0
  echo "$_now" > "$IX_HEALTH_CACHE"
fi

ix map "$FILE_PATH" >/dev/null 2>&1 || exit 0

jq -n --arg fp "$FILE_PATH" \
  '{"additionalContext": ("[ix] Graph updated — mapped: " + $fp)}'

exit 0
