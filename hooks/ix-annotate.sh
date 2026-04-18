#!/usr/bin/env bash
# ix-annotate.sh — UserPromptSubmit hook (synchronous)
#
# Fires at the start of each turn. Injects a standing instruction for Claude
# to append a concise 'Ix:' note as the final line of its response whenever
# the Ix Memory plugin provided context during the turn.
#
# Because the instruction arrives before the response, Claude writes the Ix:
# line as part of its main response — not as a separate continuation.
#
# Set IX_ANNOTATE_MODE=off to silence.

set -euo pipefail

INPUT=$(cat)
[ -n "${INPUT:-}" ] || exit 0

[ "${IX_ANNOTATE_MODE:-brief}" != "off" ] || exit 0

_json_escape() {
  printf '%s' "${1:-}" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

_HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${_HOOK_DIR}/lib/index.sh" 2>/dev/null || exit 0

ix_health_check || exit 0

_instruction="If the Ix Memory plugin provided any [ix ...] context during this turn (visible in tool additionalContext), append a single 'Ix:' line at the very end of your response. One sentence, specific: what did Ix find, flag, or prevent, and why did it help? For example: what symbol was located, what blast radius was surfaced, or what grep scan was skipped. Only include the Ix: line if [ix] context actually appeared this turn — omit it entirely otherwise."

printf '{"systemMessage":"%s"}\n' "$(_json_escape "$_instruction")"
exit 0
