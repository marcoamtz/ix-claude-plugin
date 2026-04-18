#!/usr/bin/env bash
# ix-bash.sh — PreToolUse hook for Bash
#
# Fires before Claude runs a Bash command. Detects grep/rg search patterns and
# front-runs them with ix text + ix locate for graph-aware results.
#
# Output is a CONCISE one-line summary — not raw JSON dumps.
#
# Exit 0 + JSON stdout → injects additionalContext, Bash still runs
# Exit 0 + no stdout  → no-op, Bash runs normally

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0

# Only intercept grep/rg invocations
echo "$COMMAND" | grep -qE '^\s*(grep|rg)\s' || exit 0

# ── Shared library ────────────────────────────────────────────────────────────
_HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${_HOOK_DIR}/lib/index.sh"

ix_health_check
IX_HOOK_NAME="ix-bash"
_t0=$(date +%s%3N 2>/dev/null || echo 0)
ix_log "ENTRY command='${COMMAND:0:80}'"

# ── Extract search pattern from command ────────────────────────────────────────
PATTERN=""
PATTERN=$(echo "$COMMAND" | sed -E 's/.*\s"([^"]+)".*/\1/' 2>/dev/null) || PATTERN=""
if [ -z "$PATTERN" ] || [ "$PATTERN" = "$COMMAND" ]; then
  PATTERN=$(echo "$COMMAND" | sed -E "s/.*\s'([^']+)'.*/\1/" 2>/dev/null) || PATTERN=""
fi
if [ -z "$PATTERN" ] || [ "$PATTERN" = "$COMMAND" ]; then
  PATTERN=$(echo "$COMMAND" | sed -E 's/^\s*(grep|rg)\s+(-[a-zA-Z0-9]+\s+|--[a-zA-Z-]+=\S+\s+)*([^-][^ ]*).*/\3/' 2>/dev/null) || PATTERN=""
fi

[ -z "$PATTERN" ] && { ix_log "SKIP could not extract pattern"; exit 0; }
[ ${#PATTERN} -lt 3 ] && { ix_log "SKIP pattern too short"; exit 0; }
if [ "${IX_SKIP_SECRET_PATTERNS:-1}" = "1" ] && ix_looks_like_secret "$PATTERN"; then
  ix_log "SKIP looks like secret/token"
  exit 0
fi
ix_log "PATTERN extracted='$PATTERN'"

# ── Run ix text + ix locate in parallel ───────────────────────────────────────
ix_log "RUN ix text+locate pattern='$PATTERN'"
ix_run_text_locate "$PATTERN"

[ -z "$_TEXT_RAW" ] && [ -z "$_LOC_RAW" ] && { ix_log "SKIP empty ix results"; exit 0; }

# ── Summarise results ─────────────────────────────────────────────────────────
ix_summarize_text "$_TEXT_RAW"
ix_summarize_locate "$_LOC_RAW"
ix_log "RESULTS text='${TEXT_PART:-<none>}' locate='${LOC_PART:-<none>}'"

[ -z "$TEXT_PART" ] && [ -z "$LOC_PART" ] && { ix_log "SKIP summarize produced no content"; exit 0; }

CONTEXT="[ix] bash grep intercepted for '${PATTERN}'"
[ -n "$LOC_PART" ]  && CONTEXT="${CONTEXT} — ${LOC_PART}"
[ -n "$TEXT_PART" ] && CONTEXT="${CONTEXT} | ${TEXT_PART}"
CONTEXT="${CONTEXT} | Prefer: ix text '${PATTERN}' or ix locate '${PATTERN}' over shell grep"

_elapsed_ms=$(( $(date +%s%3N 2>/dev/null || echo 0) - _t0 ))
ix_log "DECISION augment ${#CONTEXT} chars (${_elapsed_ms}ms)"
ix_ledger_append "PreToolUse" "Bash" "${#CONTEXT}" "text,locate" "1" "" "$_elapsed_ms"

if [ "${IX_HOOK_OUTPUT_STYLE:-legacy}" = "structured" ]; then
  jq -n --arg ctx "$CONTEXT" '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "allow",
      "additionalContext": $ctx
    }
  }'
else
  jq -n --arg ctx "$CONTEXT" '{"additionalContext": $ctx}'
fi
exit 0
