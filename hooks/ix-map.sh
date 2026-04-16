#!/usr/bin/env bash
# ix-map.sh — Stop hook (async)
#
# Fires after Claude finishes each response. Runs ix map asynchronously to
# keep the architectural graph current so the next session starts fresh.
#
# Annotation (the "ix: ..." summary) is handled by ix-annotate.sh, which runs
# synchronously before this hook so the message appears before the session ends.

set -euo pipefail

# ── Shared library ────────────────────────────────────────────────────────────
_HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${_HOOK_DIR}/lib/index.sh" 2>/dev/null || true

ix_health_check

# ── Debounce — skip if a map ran recently ────────────────────────────────────
IX_MAP_DEBOUNCE_SECONDS="${IX_MAP_DEBOUNCE_SECONDS:-300}"
IX_MAP_DEBOUNCE_FILE="${TMPDIR:-/tmp}/ix-map-last"
_now=$(date +%s)
_skip_map=0
if [ -f "$IX_MAP_DEBOUNCE_FILE" ]; then
  _last=$(cat "$IX_MAP_DEBOUNCE_FILE" 2>/dev/null || echo 0)
  (( (_now - _last) < IX_MAP_DEBOUNCE_SECONDS )) && _skip_map=1
fi

# ── flock — skip if another map is already running ───────────────────────────
IX_MAP_LOCK_PATH="${IX_MAP_LOCK_PATH:-${TMPDIR:-/tmp}/ix-map.lock}"
if [ "$_skip_map" -eq 0 ] && command -v flock >/dev/null 2>&1; then
  exec 9>"$IX_MAP_LOCK_PATH"
  if ! flock -n 9; then
    _skip_map=1
    ix_ledger_append "Stop" "map_skipped_lock" "0" "" "1" "" "0"
  fi
fi

# ── Run map (Claude Code's async runner handles timeout) ─────────────────────
if [ "$_skip_map" -eq 0 ]; then
  echo "$_now" > "$IX_MAP_DEBOUNCE_FILE"
  ix map >/dev/null 2>&1 || ix_capture_async "ix" "ix-map" "full map failed" "$?" "ix map" ""
fi

exit 0
