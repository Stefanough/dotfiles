#!/usr/bin/env bash
# Sets the pane title to "<state> <project> · <session title>" (●=working ?=needs approval ✓=done).

MAX_CHARS=120
TRANSCRIPT_TAIL_BYTES=1048576

[ -n "${TMUX_PANE:-}" ] || exit 0
command -v tmux >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

IFS=$'\x1f' read -r event project transcript notification prompt < <(
  jq -r '[
      .hook_event_name // "",
      (.cwd // "" | split("/") | last // ""),
      .transcript_path // "",
      .notification_type // "",
      .prompt // ""
    ] | map(gsub("[\\s\u001f]+"; " ")) | join("\u001f")' 2>/dev/null
)

case "$event" in
  UserPromptSubmit | PreToolUse | PostToolUse) state="●" ;;
  Stop) state="✓" ;;
  Notification)
    case "$notification" in
      permission_prompt | elicitation_dialog) state="?" ;;
      *) exit 0 ;;
    esac
    ;;
  *) exit 0 ;;
esac

case "$prompt" in
  "<"* | "/"*) prompt="" ;;
esac

topic=""
if [ -f "$transcript" ]; then
  topic=$(
    tail -c "$TRANSCRIPT_TAIL_BYTES" "$transcript" \
      | grep -E '"type":"(custom-title|ai-title|last-prompt)"' \
      | jq -Rrs --arg prompt "$prompt" '
          [split("\n")[] | fromjson?] as $entries
          | ([$entries[] | .customTitle // empty] | last)
            // ([$entries[] | .aiTitle // empty] | last)
            // (if $prompt != "" then $prompt else null end)
            // ([$entries[] | .lastPrompt // empty | select(test("^\\s*[</]") | not)] | last)
            // ""' 2>/dev/null
  )
fi
[ -n "$topic" ] || topic="$prompt"

title="$state ${project:-claude}"
[ -n "$topic" ] && title="$title · $topic"
title=$(printf '%s' "$title" | tr '\n\r\t#' '   _' | sed 's/  */ /g; s/ *$//' | cut -c "1-$MAX_CHARS")

tmux select-pane -t "$TMUX_PANE" -T "$title" >/dev/null 2>&1
exit 0
