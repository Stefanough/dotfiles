#!/bin/bash

################################################################################
# Format Bash prompt
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
  PS1="${PURPLE}〉${COLOR_RESET}"
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


################################################################################
# Integrations
################################################################################

# brew installations
# PATH="/usr/local/bin:$PATH"
# Do these need to be exported?
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"
export PATH="/opt/homebrew/Cellar/libpq/**/bin:$PATH"
# PATH="/opt/homebrew/bin:$PATH"

# fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# bat
export BAT_THEME="Solarized (light)"

# Git autocompletion
if [ -f ~/.git-completion.bash ]; then
  source ~/.git-completion.bash
fi

# GitHub command line tool autocompletion
if [ -f ~/.gh-completion.bash ]; then
  source ~/.gh-completion.bash
fi

# NPM bash completion
if [ -f ~/.npm-completion.bash ]; then
  source ~/.npm-completion.bash
fi

# Apollo Rover
if [ -f ~/.rover/env ]; then
  source ~/.rover/env
fi

# Elastic Beanstalk CLI
export PATH="/Users/armitage/.ebcli-virtual-env/executables:$PATH"

# nvm
export NVM_DIR="$HOME/.nvm"
# This loads nvm
# shellcheck disable=SC1091
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# This loads nvm bash_completion
# shellcheck disable=SC1091
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# bash completions installed with homebrew
# [ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

# Python stuff

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
  eval "$(pyenv init --path)" # pyenv not working without second line on Better comp. Remove on other systems?
fi

# pnpm
export PNPM_HOME="/Users/stefan.armijo/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# bash-completion https://salsa.debian.org/debian/bash-completion
# test if exists and source file
[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"


################################################################################
#
# Aliases
#
################################################################################

# pass clipboard to jq
alias pjq='pbpaste | jq'

# show trailing slash on directories
alias ls='ls -F'

# show globaly installed npm packages
alias npmglobal='npm list -g --depth 0'

# create a directory and enter
mkcd() { mkdir -p "$1"; cd "$1" || return; }

# create (nested) directory and file.
mktouch() {
  # split arg into an array. Flags; -r read raw input, -a read to array.
  IFS='/' read -r -a PATH_ARRAY <<< "$1"
  DIR_PATH="."

  # Iter except last ele of PATH_ARRAY. Join with '/'. Last ele is file name.
  # ((...)) notation allows for arithmetic.
  for part in "${PATH_ARRAY[@]}"; do
    if [ "$part" == "${PATH_ARRAY[(("${#PATH_ARRAY[@]}" - 1))]}" ]; then
      FILE_NAME="$part"
    else
      DIR_PATH="$DIR_PATH/$part"
    fi
  done

  # # create directory from joined string
  mkdir -p "$DIR_PATH";

  # # touch file with name of last element of PATH_ARRAY
  touch "$DIR_PATH/$FILE_NAME"
}

# create a new file and parent directories if they don't exist
# check for directory in pwd
# mktouch() {
#   THING=()
#   IFS=/ read -ra ADDR <<< "$IN"
#   for i in "${ADDR[@]}"; do
#     THING+=(i)
#   done
#   # IN="$1"
#   # arrINPUT=("${IN//;/ }")
#   echo "$THING"
# }

alias pgup='pg_ctl -D /usr/local/var/postgres start'
alias pgdown='pg_ctl -D /usr/local/var/postgres stop'

# pip = pip3
alias pip=pip3

# Git aliases. Move to .gitconfig?
alias gs='git status -s'
alias gl='git log --abbrev-commit'
alias glo='git log --oneline'
# alias gc='git checkout'
alias gcm='git commit -m'
alias gan='git commit --amend --no-edit'
alias ga='git add'
alias gb='git branch'
alias gcb='git checkout -b'
alias grv='git remote -v'
alias gsl='git stash list'
alias gsp='git stash pop'
alias lsjq='ls -A | jq -R "[.]" | jq -s "add"'
[ -f ~/.fzf.bash ] && alias gcf='git checkout $(git branch --all | fzf)'
__git_complete gs _git_status
__git_complete gc _git_checkout
__git_complete ga _git_add


################################################################################
#
# Exports
#
################################################################################

export PATH="/usr/local/sbin:$PATH"


################################################################################
#
# Company Specific Config sourced from ~/companySpecificShellConfig
#
################################################################################

COMPANY_SPECIFIC_SHELL_CONFIG="$HOME/companySpecificShellConfig"

if [ -d "${COMPANY_SPECIFIC_SHELL_CONFIG}" ]; then
    company_config_files=$(ls "${COMPANY_SPECIFIC_SHELL_CONFIG}")

    # Does not work for hidden (dot) files.
    for i in $company_config_files; do
      source "${COMPANY_SPECIFIC_SHELL_CONFIG}/${i}"
    done
 fi
source "/Users/armitage/.rover/env"


################################################################################
#
# mac os adjustments
#
################################################################################

# TODO: Move to setup script?
# Disable font smoothing for Alacritty
# defaults write org.alacritty AppleFontSmoothing -int 0
