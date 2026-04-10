#!/usr/bin/env bash
# ix-briefing.sh — UserPromptSubmit hook
#
# Fires at the start of each user prompt. Injects a compact ix session briefing
# once per 10 minutes. Requires ix pro — no-op if pro is not installed.
#
# Exit 0 + JSON stdout → injects additionalContext into the prompt
# Exit 0 + no stdout  → no-op

set -euo pipefail

BRIEFING_TTL=600  # 10 minutes

# Bail silently if ix is not in PATH
command -v ix >/dev/null 2>&1 || exit 0

# ── Shared library ────────────────────────────────────────────────────────────
_HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${_HOOK_DIR}/lib/index.sh"

IX_BRIEFING_CACHE="${TMPDIR:-/tmp}/ix-briefing-cache"
_now=$(date +%s)

# If briefing cache is fresh, stay silent (already injected this window)
if [ -f "$IX_BRIEFING_CACHE" ]; then
  _cached_time=$(head -1 "$IX_BRIEFING_CACHE" 2>/dev/null || echo 0)
  if (( (_now - _cached_time) < BRIEFING_TTL )); then
    exit 0
  fi
fi

# ── Health + pro check ────────────────────────────────────────────────────────
ix_health_check
ix_check_pro

_bfr_err=$(mktemp)
BRIEFING=$(ix briefing --format json 2>"$_bfr_err") || {
  _exit=$?
  ix_capture_async "ix" "ix-briefing" "ix briefing failed" "$_exit" \
    "ix briefing" "$(head -3 "$_bfr_err")"
  rm -f "$_bfr_err"
  exit 0
}
rm -f "$_bfr_err"
[ -z "$BRIEFING" ] && exit 0

{ echo "$_now"; echo "$BRIEFING"; } > "$IX_BRIEFING_CACHE"

jq -n --arg b "$BRIEFING" \
  '{"additionalContext": ("[ix] Session briefing:\n" + $b)}'
exit 0
