#!/usr/bin/env bash
# UserPromptSubmit hook: mirror the submitted prompt into the tmux pane title.

MIN_LEN=15
MAX_BYTES=200

[ -n "${TMUX_PANE:-}" ] || exit 0
command -v tmux >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

prompt=$(cat | jq -r '.prompt // empty' 2>/dev/null)

case "$prompt" in
  "" | /*) exit 0 ;;
esac

title=$(
  printf '%s' "$prompt" \
    | tr '\n\r\t#' '   _' \
    | sed 's/  */ /g; s/^ //; s/ *$//' \
    | head -c "$MAX_BYTES"
)

[ ${#title} -ge $MIN_LEN ] || exit 0

tmux select-pane -t "$TMUX_PANE" -T "$title" >/dev/null 2>&1
exit 0
