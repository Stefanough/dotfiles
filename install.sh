#!/bin/sh

# Install HomeBrew and listed packages.

echo 'Installing Homebrew...'

echo 'Downloading Homebrew installer...'
# -f fail silently,
# -L redo request with returned location (server indicates that requested
# resource has moved
# -s silent. Don't show progress meters
# -S show error. When used with -s will still show errors.
# -o output to file instead of stdout
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
run brew bundle --verbose --no-lock --file="packages.personal.Brewfile"
