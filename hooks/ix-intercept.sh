#!/usr/bin/env bash
# ix-intercept.sh — PreToolUse hook for Grep and Glob
#
# Fires before Grep/Glob executes. Runs ix text + ix locate/inventory in
# parallel and injects a CONCISE one-line summary as additionalContext so
# Claude has a graph-aware answer before the native tool runs.
#
# Output is a single line, not raw JSON dumps — designed to be acted on,
# not skipped over.
#
# Exit 0 + JSON stdout → injects additionalContext, native tool still runs
# Exit 0 + no stdout  → no-op, native tool runs normally

set -euo pipefail

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
[ -z "$TOOL" ] && exit 0

command -v ix >/dev/null 2>&1 || exit 0

# ── Shared library ────────────────────────────────────────────────────────────
_HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${_HOOK_DIR}/lib/index.sh"

ix_health_check

# ── Grep: text/symbol search ──────────────────────────────────────────────────
if [ "$TOOL" = "Grep" ]; then
  PATTERN=$(echo "$INPUT" | jq -r '.tool_input.pattern // empty')
  [ -z "$PATTERN" ] && exit 0
  [ ${#PATTERN} -lt 3 ] && exit 0

  PATH_ARG=$(echo "$INPUT" | jq -r '.tool_input.path // empty')
  LANG_ARG=$(echo "$INPUT" | jq -r '.tool_input.type // empty')

  ix_run_text_locate "$PATTERN" "$PATH_ARG" "$LANG_ARG"

  [ -z "$_TEXT_RAW" ] && [ -z "$_LOC_RAW" ] && exit 0

  ix_summarize_text "$_TEXT_RAW"
  ix_summarize_locate "$_LOC_RAW"

  # Gate on graph confidence from locate result
  CONF_WARN=""
  if [ -n "$_LOC_RAW" ]; then
    _LOC_JSON=$(parse_json "$_LOC_RAW")
    if [ -n "$_LOC_JSON" ]; then
      _confidence=$(echo "$_LOC_JSON" | jq -r '(.confidence // (.resolvedTarget.confidence // 1)) | tostring' 2>/dev/null || echo "1")
      if awk "BEGIN {c=${_confidence}+0; exit !(c < 0.3)}"; then
        LOC_PART=""  # confidence too low — drop symbol data, keep text hits
      elif awk "BEGIN {c=${_confidence}+0; exit !(c < 0.6)}"; then
        CONF_WARN="⚠ Graph confidence low (${_confidence}) — treat structural data as approximate"
      fi
    fi
  fi

  [ -z "$TEXT_PART" ] && [ -z "$LOC_PART" ] && exit 0

  CONTEXT="[ix] '${PATTERN}'"
  [ -n "$LOC_PART" ]  && CONTEXT="${CONTEXT} — ${LOC_PART}"
  [ -n "$TEXT_PART" ] && CONTEXT="${CONTEXT} | ${TEXT_PART}"
  CONTEXT="${CONTEXT} | Use ix explain/trace/impact for deeper analysis, ix read <symbol> for source"
  [ -n "$CONF_WARN" ] && CONTEXT="${CONF_WARN} | ${CONTEXT}"

# ── Glob: file pattern search ─────────────────────────────────────────────────
elif [ "$TOOL" = "Glob" ]; then
  PATTERN=$(echo "$INPUT" | jq -r '.tool_input.pattern // empty')
  [ -z "$PATTERN" ] && exit 0

  PATH_ARG=$(echo "$INPUT" | jq -r '.tool_input.path // empty')
  [ -z "$PATH_ARG" ] && exit 0

  INV_ARGS=("--format" "json" "--path" "$PATH_ARG")

  _inv_err=$(mktemp)
  INV_RAW=$(ix inventory "${INV_ARGS[@]}" 2>"$_inv_err") || {
    _exit=$?
    ix_capture_async "ix" "ix-inventory" "inventory failed" "$_exit" \
      "ix inventory '$PATH_ARG'" "$(head -3 "$_inv_err")"
    rm -f "$_inv_err"
    exit 0
  }
  rm -f "$_inv_err"
  [ -z "$INV_RAW" ] && exit 0

  INV_JSON=$(parse_json "$INV_RAW")
  [ -z "$INV_JSON" ] && exit 0

  TOTAL=$(echo "$INV_JSON" | jq -r '(.summary.total // (.results | length) // 0)' 2>/dev/null || echo 0)
  SAMPLE=$(echo "$INV_JSON" | jq -r '[.results[:5][].name] | join(", ")' 2>/dev/null || echo "")

  [ "${TOTAL:-0}" -eq 0 ] && exit 0

  CONTEXT="[ix] glob '${PATTERN}' in ${PATH_ARG}: ${TOTAL} entities"
  [ -n "$SAMPLE" ] && CONTEXT="${CONTEXT} — ${SAMPLE}$([ "${TOTAL}" -gt 5 ] && echo ' ...' || echo '')"

else
  exit 0
fi

[ -z "${CONTEXT:-}" ] && exit 0

jq -n --arg ctx "$CONTEXT" '{"additionalContext": $ctx}'
exit 0
