export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

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
alias mkcd='_(){ mkdir $1; cd $1; }; _'

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
