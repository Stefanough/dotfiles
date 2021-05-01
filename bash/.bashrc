
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
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
