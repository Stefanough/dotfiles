# Dotfiles
Maintained and versioned config across machines.

## Setup

### Clone
Clone the repo into your home directory. These files should be located in
`~/dotfiles`.

### Install
Make `install.sh` executable and run. Installs HomeBrew and the packages
defined in `packages.personal.Brewfile`.

1. `cd dotfiles/`
1. `chmod -R 777 install.sh`
1. `./install.sh`

Options:
 - `-d`
Dry-Run. No side effects.

 - `-s`
 Attempt to `stow` packages using GNU stow. This will symlink defined packages
 to your home directory if there is no existing file or directory with the same
 name.


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

### VS Code Extensions
The `vscode_ext_install` script will install VS Code extensions stored in the
`VSCode/extensions.txt` file using VS Code's `--install-extension` command.

Options:
 - `-d`
Dry-Run. No side effects.

### Maintenance
- Update Brewfile with current packages: `brew bundle dump -f --no-vscode`.
- Update VSCode/extensions.txt: `code --list-extensions > VSCode/extensions.txt`

### TODO
* Better way to export PATH to bashrc.
* Install NVM?

## Adding Existing Configuration to Dotfiles
1. Create a directory for the target config. For example
2. Copy existing directory to the new directory.
3. Run `stow <directory name>` to symlink the directory back to your home
   directory (default).
