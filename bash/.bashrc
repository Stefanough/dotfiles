#!/bin/bash

################################################################################
#
# Set up prompt style
#
################################################################################

function parse_git_branch {
   git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Configure prompt format
export PS1="\[\e[00;36m\]\w\$(parse_git_branch): \\$ \[\e[0m\]"


################################################################################
#
# Integrations
#
################################################################################

# brew installations
# PATH="/usr/local/bin:$PATH"
# Do these need to be exported?
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"
# PATH="/opt/homebrew/bin:$PATH"

# fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# bat
export BAT_THEME="Solarized (light)"

# Git autocompletion
# source ~/.git-completion.bash
if [ -f ~/.git-completion.bash ]; then
  source ~/.git-completion.bash
fi

# GitHub command line tool autocompletion
# source ~/.gh-completion.bash
if [ -f ~/.gh-completion.bash ]; then
  source ~/.gh-completion.bash
fi

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

thing() { echo "do not leave your computer unlocked, nerd." && \cd "$@" || exit; }

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
alias cd=thing
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

    for i in $company_config_files; do
      source "${COMPANY_SPECIFIC_SHELL_CONFIG}/${i}"
    done
 fi
