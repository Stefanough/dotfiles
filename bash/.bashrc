##########################
#
# Set up prompt style
#
##########################

function parse_git_branch {
   git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Configure prompt format
export PS1="\[\e[00;36m\]\w\$(parse_git_branch): \\$ \[\e[0m\]"


##########################
#
# Integrations
#
##########################

# fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Git autocompletion
source ~/.git-completion.bash

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# bash completions installed with homebrew
# [ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

# Python stuff

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi


##########################
#
# Aliases
#
##########################

# show trailing slash on directories
alias ls='ls -F'

# show globaly installed npm packages
alias npmglobal='npm list -g --depth 0'

# create a directory and enter
alias mkcd='_(){ mkdir -p $1; cd $1; }; _'

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
alias ga='git add'
alias gb='git branch'
alias gcb='git checkout -b'
alias grv='git remote -v'
alias gsl='git stash list'
alias gsp='git stash pop'
alias lsjq='ls -A | jq -R "[.]" | jq -s "add"'
alias cd='echo "do not leave your computer unlocked nerd." && cd $*'

__git_complete gs _git_status
__git_complete gc _git_checkout
__git_complete ga _git_add


##########################
#
# Exports
#
##########################

export PATH="/usr/local/sbin:$PATH"
