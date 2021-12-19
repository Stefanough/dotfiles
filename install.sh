#!/bin/sh

# Install HomeBrew and listed packages.

# TODO:
# set faster scroll speed for mac if possible
# set default shell to bash

# Check if Brew is installed. If it is, exit with 0.
# The command builtin runs commands.
# flags:
#   -v writes the pathname or name of the command that would be executed. 
if command -v brew &> /dev/null; then
  echo "Brew appears to be installed already."
  exit 0
fi

echo 'Installing Homebrew...'

echo 'Downloading Homebrew installer...'
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

brew bundle --verbose --no-lock --file="packages.personal.Brewfile"
