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
1. `chmod +x install.sh`
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

## Agent Harnesses (Claude Code, Codex, pi)

These packages track **authored config only** — settings, rules, hooks, skills,
keybindings. They must never track runtime state: credentials, session
transcripts, sqlite databases, approval logs, or vendored skills the tool
reinstalls on upgrade.

### The folding rule

Agent harnesses write runtime state into their dot-directory. If `stow` links
that directory as a single symlink, the tool writes its credentials and session
history straight into this repo. Stow does exactly that when the target does not
yet exist — which is always true on a new laptop.

Harness packages are therefore stowed with `--no-folding`, which builds a real
directory and symlinks individual files into it. `install.sh` handles this via
`NO_FOLDING_PACKAGES`. Stow these by hand the same way:

```
stow --no-folding claude
```

Verify a harness is linked correctly — the dot-directory should be a real
directory, not a symlink:

```
ls -ld ~/.claude   # drwxr-xr-x  = correct
                   # lrwxr-xr-x  = folded, runtime state is in the repo
```

`migrate-codex-runtime` converts an already-folded `~/.codex` to this layout. It
is a dry run unless passed `-x`.

### Gitignore posture

Harness packages use **allowlists**, not denylists — anything a future release
adds stays ignored until it is named. When adding a config file to a harness
package, add a matching `!` line.

### Plugins and MCP servers

Claude Code owns `~/.claude/plugins` and `~/.claude.json`, so those are not
stowed. They are reproduced from manifests instead:

- `claude/.claude/plugin-manifest.json` — marketplaces and plugin ids
- `claude/.claude/mcp-servers.json` — MCP servers, secrets as `${VAR}`

Reinstall with `claude/.claude/scripts/install-plugins.sh` and
`install-mcp-servers.sh` (both take `-d` for a dry run, both are idempotent).
`install.sh` offers to run them.

**Secrets never go in the manifest.** `install-mcp-servers.sh` resolves `${VAR}`
placeholders from the environment, falling back to
`~/.config/dotfiles/secrets.env` (outside the repo). A server with unresolved
placeholders is skipped and reported. Current requirements:

```
ATLASSIAN_API_TOKEN=...
CONTEXT7_API_KEY=...
```

To refresh the manifests after installing a plugin or MCP server, update the
JSON by hand — they are the source of truth, not a dump of live state.

## Adding Existing Configuration to Dotfiles
1. Create a directory for the target config. For example, `mkdir ~/dotfiles/ghostty`.
2. Copy existing config into the new directory, mirroring the path relative to home.
3. Run `stow <directory name>` to symlink the directory back to your home
   directory (default). For agent harnesses, use `stow --no-folding <name>` —
   see the folding rule above.
