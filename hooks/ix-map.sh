#!/usr/bin/env bash
# ix-map.sh — Stop hook
#
# Fires after Claude finishes each response. Runs ix map asynchronously to
# keep the architectural graph current so the next session starts fresh.
#
# Runs async (does not block Claude's response or session end).

set -euo pipefail

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

nohup ix map >/dev/null 2>&1 &
disown

exit 0
