export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Add knot to PATH
export PATH=$PATH:$PWD/tools/knot/bin2

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:/Users/sarmijo/mono/tools/knot/bin2"

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# source /Users/sarmijo/Library/Preferences/org.dystroy.broot/launcher/bash/br

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.

# Show trailing slash on directories
alias ls='ls -F'

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
