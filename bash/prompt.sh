#!/bin/bash

################################################################################
#
# Format Bash prompt
#
################################################################################

# Colors based on https://www.cyberciti.biz/faq/bash-shell-change-the-color-of-my-shell-prompt-under-linux-or-unix/
BLACK="\[\033[30m\]"
PURPLE="\[\e[00;35m\]"
RED="\[\e[00;31m\]"
GREEN="\[\e[00;32m\]"
CYAN="\[\e[00;36m\]"
COLOR_RESET="\[\e[0m\]"


function is_git_repository {
  git branch > /dev/null 2>&1
}

function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

function compose_prompt {
  # Set terminal/tmux pane title to user@hostname
  PS1="\[\033]2;\u@\h\007\]"
  PS1+="${PURPLE}〉${COLOR_RESET}"
  PS1+="${CYAN}\w${COLOR_RESET}"
  if is_git_repository; then
    PS1+="${BLACK}(${COLOR_RESET}"
    if [ -z "$(git status --porcelain)" ]; then
      PS1+="${GREEN}$(parse_git_branch)${COLOR_RESET}"
    else
      PS1+="${RED}$(parse_git_branch)${COLOR_RESET}"
    fi
    PS1+="${BLACK})${COLOR_RESET}"
  fi
  PS1+="${COLOR_RESET} $ "

  export PS1
}

# Specific to Python venvs. See activate script.
function venv_prefix {
    if [ -z "$VIRTUAL_ENV_DISABLE_PROMPT" ] ; then
        _OLD_VIRTUAL_PS1="$PS1"
        if [ "$(basename \""$VIRTUAL_ENV"\")" = "__" ] ; then
            PS1="[$(basename \`dirname \""$VIRTUAL_ENV"\"\`)] $PS1"

        elif [ "$VIRTUAL_ENV" != "" ]; then
            PS1="($(basename "$VIRTUAL_ENV"))$PS1"
        fi
    fi

    export PS1
}

function set_prompt {
  compose_prompt
  venv_prefix
}

export PROMPT_COMMAND=set_prompt
