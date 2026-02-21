#!/bin/bash

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')

cd "$cwd" 2>/dev/null || cwd=$(pwd)

# Replace home directory with ~
cwd="${cwd/#$HOME/~}"

PURPLE=$(printf '\033[00;35m')
RED=$(printf '\033[00;31m')
GREEN=$(printf '\033[00;32m')
CYAN=$(printf '\033[00;36m')
YELLOW=$(printf '\033[00;33m')
BLACK=$(printf '\033[30m')
RESET=$(printf '\033[0m')

output="${PURPLE}〉${RESET}"
output+="${CYAN}${cwd}${RESET}"

if git -c advice.detachedHead=false -c core.fileMode=false branch > /dev/null 2>&1; then
  branch=$(git -c advice.detachedHead=false -c core.fileMode=false branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')

  output+="${BLACK}(${RESET}"

  if [ -z "$(git -c core.fileMode=false --no-optional-locks status --porcelain 2>/dev/null)" ]; then
    output+="${GREEN}${branch}${RESET}"
  else
    output+="${RED}${branch}${RESET}"
  fi

  output+="${BLACK})${RESET}"
fi

# Add context usage information
context_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

if [ -n "$context_size" ] && [ -n "$used_pct" ]; then
  # Calculate used tokens from percentage and context size
  used_tokens=$(( context_size * used_pct / 100 ))

  # Format with k/M suffix for readability
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

  formatted_used=$(format_tokens "$used_tokens")
  formatted_size=$(format_tokens "$context_size")

  # Color code based on usage percentage
  pct_int=${used_pct%.*}
  if [ "$pct_int" -ge 80 ]; then
    pct_color=$RED
  elif [ "$pct_int" -ge 60 ]; then
    pct_color=$YELLOW
  else
    pct_color=$GREEN
  fi

  output+=" ${BLACK}[${RESET}"
  output+="${pct_color}${formatted_used}${BLACK}/${RESET}${formatted_size}"
  output+=" ${BLACK}|${RESET} ${pct_color}${used_pct}%${RESET}"
  output+="${BLACK}]${RESET}"
fi

printf '%s' "$output"
