#!/usr/bin/env bash
# ix-briefing.sh — UserPromptSubmit hook
#
# Fires at the start of each user prompt. Injects a compact ix session briefing
# once per 10 minutes when ix Pro is available. When model-authored annotation
# is enabled, also injects a one-time instruction telling Claude to end its
# response with a terse "Ix:" line inferred from the [ix] context it saw.
#
# Exit 0 + JSON stdout → injects additionalContext into the prompt
# Exit 0 + no stdout  → no-op

set -euo pipefail

BRIEFING_TTL=600  # 10 minutes
INPUT=$(cat)

# Bail silently if ix is not in PATH
# ── Shared library ────────────────────────────────────────────────────────────
_HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${_HOOK_DIR}/lib/index.sh"

IX_BRIEFING_CACHE="${TMPDIR:-/tmp}/ix-briefing-cache"
_now=$(date +%s)
_channel="${IX_ANNOTATE_CHANNEL:-modelSuffix}"
_mode="${IX_ANNOTATE_MODE:-off}"
_ANNOTATE_CACHE="${TMPDIR:-/tmp}/ix-model-annotation-instructed"
_annotation_instruction=""

if [ "$_mode" != "off" ] && { [ "$_channel" = "modelSuffix" ] || [ "$_channel" = "both" ]; }; then
  if [ ! -f "$_ANNOTATE_CACHE" ]; then
    touch "$_ANNOTATE_CACHE"
    _annotation_instruction='[ix meta] Attribution: if you received any lines starting with [ix] since the last user message, end your response with one short final line starting with "Ix:". Use one terse sentence by default; use two short sentences only if one sentence would be awkward. Keep the whole Ix note under about 18 words when possible and never over 25 words. Infer only from the [ix] lines you actually saw. Keep it factual. Do not mention search, read, edit, or session context unless it actually happened. Do not add an Ix line if you received no [ix] lines. Example: Ix: surfaced symbol matches before search and checked file context before read.'
  fi
fi

_briefing_fresh=0
if [ -f "$IX_BRIEFING_CACHE" ]; then
  _cached_time=$(head -1 "$IX_BRIEFING_CACHE" 2>/dev/null || echo 0)
  if (( (_now - _cached_time) < BRIEFING_TTL )); then
    _briefing_fresh=1
  fi
fi

if [ "$_briefing_fresh" -eq 1 ] && [ -z "$_annotation_instruction" ]; then
  exit 0
fi

# ── Health + pro check ────────────────────────────────────────────────────────
ix_health_check
IX_HOOK_NAME="ix-briefing"
_t0=$(date +%s%3N 2>/dev/null || echo 0)
ix_log "ENTRY mode=${_mode:-off} channel=${_channel:-?} fresh=${_briefing_fresh}"
BRIEFING=""
if [ "$_briefing_fresh" -eq 0 ] && ix_check_pro; then
  ix_log "RUN ix briefing (stale, Pro available)"
  _bfr_err=$(mktemp)
  BRIEFING=$(ix briefing --format json 2>"$_bfr_err") || {
    _exit=$?
    ix_capture_async "ix" "ix-briefing" "ix briefing failed" "$_exit" \
      "ix briefing" "$(head -3 "$_bfr_err")"
    rm -f "$_bfr_err"
    BRIEFING=""
  }
  rm -f "$_bfr_err"
  [ -n "$BRIEFING" ] && { echo "$_now"; echo "$BRIEFING"; } > "$IX_BRIEFING_CACHE"
  ix_log "BRIEFING result=${#BRIEFING} chars"
elif [ "$_briefing_fresh" -eq 1 ]; then
  ix_log "SKIP briefing TTL fresh"
else
  ix_log "SKIP briefing (no Pro or failed)"
fi

_elapsed_ms=$(( $(date +%s%3N 2>/dev/null || echo 0) - _t0 ))

_context=""
if [ -n "$BRIEFING" ]; then
  _context="[ix] Session briefing:\n${BRIEFING}"
  ix_ledger_append "UserPromptSubmit" "Briefing" "${#_context}" "briefing" "1" "" "$_elapsed_ms"
fi
[ -n "$_annotation_instruction" ] && {
  if [ -n "$_context" ]; then
    _context="${_context}\n${_annotation_instruction}"
  else
    _context="${_annotation_instruction}"
  fi
}

[ -n "$_context" ] || { ix_log "DECISION silent (no content to inject)"; exit 0; }
ix_log "DECISION injecting ${#_context} chars additionalContext"

jq -n --arg ctx "$_context" '{"additionalContext": $ctx}'
exit 0
