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

# ── Shared library ────────────────────────────────────────────────────────────
_HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${_HOOK_DIR}/lib/index.sh" 2>/dev/null || true

ix_health_check

nohup ix map >/dev/null 2>&1 &
disown

exit 0
