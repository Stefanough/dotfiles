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
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

if [ -n "$total_input" ] && [ -n "$total_output" ]; then
  total_tokens=$((total_input + total_output))
  # Format tokens with comma separators for readability
  formatted_tokens=$(printf "%'d" $total_tokens 2>/dev/null || echo $total_tokens)

  output+=" ${BLACK}[${RESET}"
  output+="${YELLOW}${formatted_tokens} tokens${RESET}"

  if [ -n "$used_pct" ]; then
    # Color code based on usage percentage
    pct_int=${used_pct%.*}
    if [ "$pct_int" -ge 80 ]; then
      pct_color=$RED
    elif [ "$pct_int" -ge 60 ]; then
      pct_color=$YELLOW
    else
      pct_color=$GREEN
    fi
    output+=" ${BLACK}|${RESET} ${pct_color}${used_pct}%${RESET}"
  fi

  output+="${BLACK}]${RESET}"
fi

printf '%s' "$output"
