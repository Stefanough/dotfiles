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

alias pgup='pg_ctl -D /usr/local/var/postgres start'
alias pgdown='pg_ctl -D /usr/local/var/postgres stop'

# Npm
alias npmglobal='npm list -g --depth 0'

# Filesystem stuff
alias mkcd='_(){ mkdir $1; cd $1; }; _'

alias knot-all='knot run-all federation-svc demand-svc ffne-svc launch-svc pricing-engine notify-svc property-svc supply-svc foundation'

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# Git stuff

# Git autocompletion
source ~/.git-completion.bash


function parse_git_branch { 
   git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/' 
}

# Configure prompt format
export PS1="\[\e[00;36m\]\w\$(parse_git_branch): \\$ \[\e[0m\]"

[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

__git_complete gs _git_status
__git_complete gc _git_checkout
__git_complete ga _git_add

export PATH="/usr/local/sbin:$PATH"

# source /Users/sarmijo/Library/Preferences/org.dystroy.broot/launcher/bash/br

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Python stuff

# pip = pip3
alias pip=pip3

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
