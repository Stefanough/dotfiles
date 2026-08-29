#!/bin/bash

# Columns Claude Code's own chrome consumes; raise if the right segment truncates.
EDGE_RESERVE=6
# Below this many columns of left content, drop to a bare percentage.
MIN_LEFT=24
GIT_CACHE_TTL=5

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')

cd "$cwd" 2>/dev/null || cwd=$(pwd)

cwd="${cwd/#$HOME/~}"

PURPLE=$(printf '\033[00;35m')
RED=$(printf '\033[00;31m')
GREEN=$(printf '\033[00;32m')
CYAN=$(printf '\033[00;36m')
YELLOW=$(printf '\033[00;33m')
BLACK=$(printf '\033[30m')
RESET=$(printf '\033[0m')

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

abbrev_path() {
  local p=$1 out="" part parts i n
  local IFS='/'
  read -ra parts <<< "$p"
  n=${#parts[@]}
  for ((i = 0; i < n; i++)); do
    part=${parts[i]}
    if (( i == n - 1 )) || [ -z "$part" ] || [ "$part" = "~" ]; then
      out+=$part
    else
      out+=${part:0:1}
    fi
    (( i < n - 1 )) && out+="/"
  done
  printf '%s' "$out"
}

trunc() {
  local s=$1 n=$2
  if (( n < 1 )); then
    printf ''
  elif (( ${#s} <= n )); then
    printf '%s' "$s"
  else
    printf '%s…' "${s:0:n-1}"
  fi
}

read_git_state() {
  local b=""
  if git -c advice.detachedHead=false -c core.fileMode=false branch > /dev/null 2>&1; then
    b=$(git -c advice.detachedHead=false -c core.fileMode=false branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    if [ -n "$(git -c core.fileMode=false --no-optional-locks status --porcelain 2>/dev/null)" ]; then
      printf 'dirty\t%s' "$b"
      return
    fi
  fi
  printf 'clean\t%s' "$b"
}

# refreshInterval re-runs this script on a timer; git in a large repo costs
# ~350ms, so timer ticks reuse a recent result instead of paying it again.
git_state() {
  local dir cache key mtime now
  cache="${TMPDIR:-/tmp}/claude-statusline-$(id -u)"
  mkdir -p "$cache" 2>/dev/null || { read_git_state; return; }
  key="$cache/$(printf '%s' "$PWD" | cksum | tr -d ' /')"
  now=$(date +%s)
  mtime=$(stat -f %m "$key" 2>/dev/null || stat -c %Y "$key" 2>/dev/null || echo 0)
  if (( now - mtime < GIT_CACHE_TTL )); then
    cat "$key"
    return
  fi
  read_git_state > "$key.$$" && mv -f "$key.$$" "$key"
  cat "$key"
}

state=$(git_state)
branch=${state#*$'\t'}
if [ "${state%%$'\t'*}" = dirty ]; then
  branch_color=$RED
else
  branch_color=$GREEN
fi

model=$(echo "$input" | jq -r '.model.display_name // empty')
model_short=${model%% (*}

context_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

right_plain=""
right_color=""
if [ -n "$context_size" ] && [ -n "$used_pct" ]; then
  pct_int=${used_pct%.*}
  if [ "$pct_int" -ge 80 ]; then
    pct_color=$RED
  elif [ "$pct_int" -ge 60 ]; then
    pct_color=$YELLOW
  else
    pct_color=$GREEN
  fi

  formatted_used=$(format_tokens $(( context_size * pct_int / 100 )))
  formatted_size=$(format_tokens "$context_size")

  full_plain="[${formatted_used}/${formatted_size} | ${pct_int}%]"
  full_color="${BLACK}[${RESET}${pct_color}${formatted_used}${BLACK}/${RESET}${formatted_size} ${BLACK}|${RESET} ${pct_color}${pct_int}%${RESET}${BLACK}]${RESET}"
  short_plain="${pct_int}%"
  short_color="${pct_color}${pct_int}%${RESET}"
fi

cols=${COLUMNS:-80}
usable=$(( cols - EDGE_RESERVE ))
(( usable < 20 )) && usable=20

if [ -n "$full_plain" ]; then
  if (( usable - ${#full_plain} - 1 >= MIN_LEFT )); then
    right_plain=$full_plain
    right_color=$full_color
  else
    right_plain=$short_plain
    right_color=$short_color
  fi
fi

avail=$usable
[ -n "$right_plain" ] && avail=$(( usable - ${#right_plain} - 1 ))

build_left() {
  local path_mode=$1 model_mode=$2 branch_budget=$3
  local path=$cwd m="" b=$branch

  case $path_mode in
    abbrev) path=$(abbrev_path "$cwd") ;;
    base) path=${cwd##*/} ;;
  esac

  case $model_mode in
    full) m=$model ;;
    short) m=$model_short ;;
  esac

  [ "$branch_budget" -gt 0 ] && b=$(trunc "$branch" "$branch_budget")

  left_plain="🞻 ${path}"
  left_color="${PURPLE}🞻 ${RESET}${CYAN}${path}${RESET}"

  if [ -n "$b" ]; then
    left_plain+="(${b})"
    left_color+="${BLACK}(${RESET}${branch_color}${b}${RESET}${BLACK})${RESET}"
  fi

  if [ -n "$m" ]; then
    left_plain+=" ${m}"
    left_color+=" ${PURPLE}${m}${RESET}"
  fi
}

for variant in "full full 0" "full short 0" "abbrev short 0" "abbrev none 0" "base none 0"; do
  build_left $variant
  (( ${#left_plain} <= avail )) && break
done

if (( ${#left_plain} > avail )) && [ -n "$branch" ]; then
  budget=$(( ${#branch} - (${#left_plain} - avail) ))
  (( budget < 1 )) && budget=1
  build_left base none $budget
fi

if (( ${#left_plain} > avail )); then
  left_plain=$(trunc "$left_plain" "$avail")
  left_color="${CYAN}${left_plain}${RESET}"
fi

if [ -z "$right_plain" ]; then
  printf '%s' "$left_color"
  exit 0
fi

pad=$(( usable - ${#right_plain} - ${#left_plain} ))
(( pad < 1 )) && pad=1

printf '%s%*s%s' "$left_color" "$pad" "" "$right_color"
