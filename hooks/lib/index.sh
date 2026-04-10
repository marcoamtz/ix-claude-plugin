#!/usr/bin/env bash
# hooks/lib/index.sh — Barrel entry point for all ix hook shared libraries
#
# Source this file from any hook instead of loading ix-errors.sh and ix-lib.sh
# individually. Creates a single import hub so the ix graph can see all hooks
# as a connected component rather than isolated single-file regions.
#
# Usage (from any hook in hooks/):
#   _HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   source "${_HOOK_DIR}/lib/index.sh"
#
# Exports (via ix-errors.sh):
#   IX_ERROR_MODE, IX_ERROR_STORE, ix_capture_async
#
# Exports (via ix-lib.sh):
#   IX_HEALTH_CACHE, IX_PRO_CACHE
#   ix_health_check, ix_check_pro
#   parse_json, ix_run_text_locate, ix_summarize_text, ix_summarize_locate

_IX_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${_IX_LIB_DIR}/../ix-errors.sh" 2>/dev/null || true
source "${_IX_LIB_DIR}/../ix-lib.sh"
