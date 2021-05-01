if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

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

export PATH="/usr/local/sbin:$PATH"

# Python stuff

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
