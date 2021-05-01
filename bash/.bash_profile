if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

export PATH="/usr/local/sbin:$PATH"

# Python stuff

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
