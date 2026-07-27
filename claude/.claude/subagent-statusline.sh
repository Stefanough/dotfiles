#!/bin/bash

input=$(cat)

PURPLE=$(printf '\033[00;35m')
RED=$(printf '\033[00;31m')
GREEN=$(printf '\033[00;32m')
CYAN=$(printf '\033[00;36m')
YELLOW=$(printf '\033[00;33m')
BLACK=$(printf '\033[30m')
RESET=$(printf '\033[0m')

model_short() {
  case "$1" in
    *fable*)  printf 'Fable' ;;
    *opus*)   printf 'Opus' ;;
    *sonnet*) printf 'Sonnet' ;;
    *haiku*)  printf 'Haiku' ;;
    *)        printf '%s' "$1" ;;
  esac
}

format_tokens() {
  local n=$1
  if [ "$n" -ge 1000000 ]; then
    local m=$(( n / 1000000 ))
    local remainder=$(( (n % 1000000) / 100000 ))
    if [ "$remainder" -gt 0 ]; then
      printf '%d.%dM' "$m" "$remainder"
    else
      printf '%dM' "$m"
    fi
  elif [ "$n" -ge 1000 ]; then
    printf '%dk' "$(( n / 1000 ))"
  else
    printf '%d' "$n"
  fi
}

echo "$input" | jq -r '.tasks[] | [.id, .model // "", (.tokenCount // "" | tostring), (.contextWindowSize // "" | tostring), ((.description // .name // "") | gsub("[\n\r\t]"; " "))] | join("\u001f")' |
while IFS=$'\x1f' read -r id model tokens ctx desc; do
  # No resolved model yet: keep the default row rendering
  [ -n "$model" ] || continue

  content="${PURPLE}$(model_short "$model")${RESET}"

  if [ ${#desc} -gt 60 ]; then
    desc="${desc:0:57}..."
  fi
  [ -n "$desc" ] && content+=" ${CYAN}${desc}${RESET}"

  if [ -n "$tokens" ] && [ -n "$ctx" ] && [ "$ctx" -gt 0 ]; then
    pct=$(( tokens * 100 / ctx ))
    if [ "$pct" -ge 80 ]; then
      pct_color=$RED
    elif [ "$pct" -ge 60 ]; then
      pct_color=$YELLOW
    else
      pct_color=$GREEN
    fi
    content+=" ${BLACK}[${RESET}${pct_color}$(format_tokens "$tokens")${BLACK}/${RESET}$(format_tokens "$ctx")"
    content+=" ${BLACK}|${RESET} ${pct_color}${pct}%${RESET}${BLACK}]${RESET}"
  fi

  jq -cn --arg id "$id" --arg content "$content" '{id: $id, content: $content}'
done
