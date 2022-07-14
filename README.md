# Dotfiles
Maintained and versioned config across machines.

## Setup

### clone
Clone into your home directory. These files should be located at `~/dotfiles`.

### Brew
Make `install.sh` executable and run. Installs HomeBrew and the packages
defined in `packages.personal.Brewfile`.

1. `cd dotfiles/`
1. `chmod -R 777 install.sh`
1. `./install.sh`

The install script will attempt the following operations:
1. check for and install HomeBrew
1. install packages listed in `packages.personal.Brewfile`

### GNU stow
`stow` is used to symlink files from the dotfiles directory. By default, stow
will symlink files to the parent directory. Some directories have targets
defined in a `.stowrc` file if there is a different target.

1. Install `stow`
1. clone the repo
1. `$ cd ~/dotfiles` and `$ stow <name>`

### Vim
Vim has one extra dependency: after executing `$ stow vim`, clone the Vim
package manager Vundle into `~/.vim/bundle` and run `:PluginInstall` on start.

1. `git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim`

