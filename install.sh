#!/bin/sh

# Interactive-ish installer for HomeBrew and packages, setup.
#
# options:
#   -d dry run
#
# TODO:
# set faster scroll speed for mac if possible
# set default shell to bash
# run stow on (all?) stow packages after brew install

D='false' # variable for dry run

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
#
# TODO: check for actual files at their install location instead of the command
#       in case it has not been added to path.
#
#       Check for both installation and path. If not installed, ask to install
#       If not in path, ask to add to path.
if command -v brew &> /dev/null; then
  echo "Brew appears to be already installed."
else
  echo 'Installing Homebrew...'
  echo 'Downloading Homebrew installer...'
  if [ "$D" = 'true' ]; then
    echo 'Dry run, skipping brew install script'
  else
    ##########################################################
    # Explanation of curl flags in the following command:
    #   -f fail silently,
    #   -L redo request with returned location (server indicates that requested
    #   resource has moved
    #   -s silent. Don't show progress meters
    #   -S show error. When used with -s will still show errors.
    #   -o output to file instead of stdout
    # bash flags:
    #   -c read command from the given string
    #########################################################
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
fi

# Add brew to path but do not write to config until stow has been installed
# TODO: conditional for dry run
# TODO: This file may not exist if dotfiles have not been stowed
echo 'Adding brew to path.'
  if [ "$D" = 'true' ]; then
    echo 'Dry run, brew not installed. Do not add to path!'
  else
    eval "$(/opt/homebrew/bin/brew shellenv)"


# Install packages listed in the provided Brewfile.
while true; do
  echo 'Would you like to install packages with brew bundle? y/n'
  read -r input
  case "$input" in
    y) if [ "$D" = 'true' ]; then
         echo 'Dry run, skipping install of packages.'
       else
         brew bundle --verbose --no-lock --file="packages.personal.Brewfile"
       fi
       break
       ;;
    n) break ;;
    *) echo 'y or n' ;;
  esac
done
