# Dotfiles

## Motivation

Maintaned and versioned configuration accros machines.

## Setup

GNU stow is used to symlink files from the dotfiles directory.
1. Install `stow`
2. clone the repo
3. `$ cd ~/dotfiles` and `$ stow <name>`

### Vim

Vim has one extra dependency: after executing `$ stow vim`, clone the Vim package manager Vundle into `~/.vim/bundle` and run `:PluginInstall` on start.

