#!/bin/sh

# Install HomeBrew and packages.
#
# options:
#   -d dry run
#
# TODO:
# set faster scroll speed for mac if possible
# set default shell to bash

# set variable for dry run
D='false'
while getopts 'd' flag; do
  case "${flag}" in
    d) D='true' ;;
    *) echo "Unexpected option ${flag}" >&2; exit 1 ;;
  esac
done
readonly D

# Check if Brew is installed.
#
# The command builtin runs commands.
# flags:
#   -v writes the pathname or name of the command that would be executed.
if command -v brew &> /dev/null; then
  echo "Brew appears to be already installed."
else
  echo 'Installing Homebrew...'
  echo 'Downloading Homebrew installer...'
  if [ "$D" = 'true' ]; then
    echo 'Dry run, skipping brew install script'
  else
    # curl flags:
    #   -f fail silently,
    #   -L redo request with returned location (server indicates that requested
    #   resource has moved
    #   -s silent. Don't show progress meters
    #   -S show error. When used with -s will still show errors.
    #   -o output to file instead of stdout
    # bash flags:
    #   -c read command from the given string
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
fi

# Install packages listed in the provided Brewfile.
echo 'installing packages using brew bundle...'
if [ "$D" = 'true' ]; then
  echo 'Dry run, skipping install of packages.'
else
  brew bundle --verbose --no-lock --file="packages.personal.Brewfile"
fi
