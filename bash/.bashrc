#!/bin/bash

################################################################################
#
# Format Bash prompt
#
################################################################################

source "$(dirname "${BASH_SOURCE[0]}")/prompt.sh"


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
export PATH="/opt/homebrew/Cellar/libpq/**/bin:$PATH"
# PATH="/opt/homebrew/bin:$PATH"

# fzf
eval "$(fzf --bash)"

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

# ngrok
if command -v ngrok &>/dev/null; then
  eval "$(ngrok completion)"
fi

# Elastic Beanstalk CLI
export PATH="/Users/armitage/.ebcli-virtual-env/executables:$PATH"

# nvm
export NVM_DIR="$HOME/.nvm"
# This loads nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# This loads nvm bash_completion
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
# requires bash 4.4+ for -o nosort
# if [[ ${BASH_VERSINFO[0]} -gt 4 ]] || [[ ${BASH_VERSINFO[0]} -eq 4 && ${BASH_VERSINFO[1]} -ge 4 ]]; then
[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"
# fi

################################################################################
#
# Aliases
#
################################################################################

### ls

# show trailing slash on directories
alias ls='ls -F'


### mkdir

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


### jq

# pass clipboard to jq
alias pjq='pbpaste | jq'

# directory list as JSON
alias lsjq='ls -A | jq -R "[.]" | jq -s "add"'


### npm

# show globaly installed npm packages
alias npmglobal='npm list -g --depth 0'


### pip

# pip = pip3
alias pip=pip3

### Git

# all branches in fzf
[ -f ~/.fzf.bash ] && alias gcf='git checkout $(git branch --all | fzf)'

# Git aliases. Move to .gitconfig?
alias ga='git add'
alias gan='git commit --amend --no-edit'
alias gb='git branch'
alias gc-='git checkout -'
alias gcb='git checkout -b'
alias gcm='git commit -m'
alias gl='git log --abbrev-commit'
alias glo='git log --oneline'
alias grv='git remote -v'
alias gs='git status -s'
alias gsl='git stash list --format="%gd: %cd - %s"'
alias gsp='git stash pop'

__git_complete gs _git_status
__git_complete gc _git_checkout
__git_complete ga _git_add


################################################################################
#
# secrets
#
################################################################################

# Load secrets (API keys, tokens, etc.)
[ -f ~/.secrets ] && source ~/.secrets


################################################################################
#
# Exports
#
################################################################################

export PATH="/usr/local/sbin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# ???
# export PROMPT_COMMAND="history -a; history -n"

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

################################################################################
#
# mac os adjustments
#
################################################################################

# TODO: Move to setup script?
# Disable font smoothing for Alacritty
# defaults write org.alacritty AppleFontSmoothing -int 0

# export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
# export PUPPETEER_EXECUTABLE_PATH=`which chromium`

export BASH_SILENCE_DEPRECATION_WARNING=1

# Continuous-Claude OPC directory (for skills to find scripts)
export CLAUDE_OPC_DIR="/Users/armitage/Source/Continuous-Claude-v3/opc"


################################################################################
#
# utilities
#
################################################################################

# fzf widgets — keybinding → prefix → widget
source "$HOME/scripts/fzf-widgets/core.sh"
fzf_widget_bind "\C-g" "git checkout" "$HOME/scripts/fzf-widgets/gcr.sh"
fzf_widget_bind "\C-xy" "yarn run"   "$HOME/scripts/fzf-widgets/yarn-scripts.sh"

. "$HOME/.cargo/env"
