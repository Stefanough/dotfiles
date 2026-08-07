#!/bin/bash

################################################################################
# Interactive-ish installer for HomeBrew and packages, setup.
#
# options:
#   -d dry-run. Defaults to false.
#   -s attempt to stow packages. Defaults to false.
#      WIP and may not link packages if files/directories already exist.
#
# HomeBrew binary is installed to /opt/homebrew/bin/brew based on "which brew"
#
# TODO:
#   include long flags as options
#   set faster scroll speed for mac if possible
#   set default shell to bash
#   check for already stowed packages (necessary?)
#   Is it dangerous to print command names as part of the stow prompt?
################################################################################

set -eu

readonly HOMEBREW_INSTALL_LOCATION='/opt/homebrew/bin/brew'
readonly STOW_WHITELIST=(MenuMeters alacritty bash claude codex ctags ghostty git npm pi ripgrep shellcheck tmux vim)

# Agent harnesses write runtime state (credentials, session transcripts, sqlite)
# into their dot-directory. Stow's default tree-folding would symlink the whole
# directory into this repo on a machine where the target does not yet exist,
# putting that state in the working tree. --no-folding forces per-file symlinks
# into a real directory instead. Removing a package from here is a security
# regression, not a style change.
readonly NO_FOLDING_PACKAGES=(claude codex pi)


D='false' # variable for dry run
S='false' # variable for executing stow

while getopts 'ds' flag; do
  case "${flag}" in
    d) D='true' ;;
    s) S='true' ;;
    *) echo "Unexpected option ${flag}" >&2; exit 1 ;;
  esac
done

readonly D
readonly S

# Populate identity placeholders in config files.
# Idempotent: skips if placeholders have already been replaced.
populate_identity() {
  local gitconfig="$PWD/git/.gitconfig"
  local npmrc="$PWD/npm/.npmrc"

  if grep -q 'REPLACE_EMAIL' "$gitconfig" 2>/dev/null || grep -q 'REPLACE_EMAIL' "$npmrc" 2>/dev/null; then
    echo ''
    echo 'Setting up identity in git and npm configs...'

    read -rp 'Full name: ' user_name
    read -rp 'Email: ' user_email
    read -rp 'GitHub username: ' github_user

    if [ "$D" = 'true' ]; then
      echo "Dry run — would set name=$user_name, email=$user_email, github=$github_user"
    else
      sed -i '' "s/REPLACE_NAME/$user_name/g" "$gitconfig" "$npmrc"
      sed -i '' "s/REPLACE_EMAIL/$user_email/g" "$gitconfig" "$npmrc"
      sed -i '' "s/REPLACE_GITHUB_USER/$github_user/g" "$npmrc"
      echo 'Identity written to git/.gitconfig and npm/.npmrc.'
    fi
  else
    echo 'Identity already configured, skipping.'
  fi
}

populate_identity

# Check if Brew is installed. Check at /opt/homebrew/bin/brew
if [ -f "$HOMEBREW_INSTALL_LOCATION" ]; then
  echo "Brew appears to be already installed."
else
  echo 'Installing Homebrew...'
  echo 'Downloading Homebrew installer...'
  if [ "$D" = 'true' ]; then
    echo 'Dry run, skipping brew install script'
  else

    # What do all these flags do?
    #
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

# Add brew to path but do not write to config until gnu stow has been installed
#
# The "command" builtin runs commands.
# flags:
#   -v writes the pathname or name of the command that would be executed.
if ! command -v brew &> /dev/null; then
  echo 'Adding brew to path.'
  if [ "$D" = 'true' ]; then
    echo 'Dry run, brew not installed. Do not add to path!'
  else
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  echo 'Brew already added to path.'
fi


# Install packages listed in the provided Brewfile.
while true; do
  echo 'Would you like to install packages with brew bundle? y/n'
  read -r input
  case "$input" in
    y) if [ "$D" = 'true' ]; then
         echo 'Dry run, skipping install of packages.'
       else
         echo 'Installing packages listed in packages.personal.Brewfile'
         if ! brew bundle --verbose --file="packages.personal.Brewfile"; then
           echo ''
           echo 'Some formulae failed to install. Review the output above for details.'
         fi

         # one-off for installing fzf autocomplete
         # TODO should this be executed elsewhere?
         "$(brew --prefix)/opt/fzf/install"
       fi
       break
       ;;
    n) break ;;
    *) echo 'y or n' ;;
  esac
done

# AUTOMATED STOWING IS A WIP. UNSURE IF STOWING PACKAGES WILL BE DONE INSIDE
# THIS INSTALL SCRIPT, A SEPARATE SCRIPT, OR MANUALLY.
#
# GATE BEHIND OPTIONAL FLAG FOR NOW
if [ "$S" == 'true' ]; then
  echo "Attempting to execute stow on applicable packages..."
  # check for stowed packages and stow them if they do not exist
  # get list of all directories applicable to stow
  stow_files=$(ls "$PWD" )
  i=1

  for j in $stow_files; do
    # if name in whitelist, add to list
    for k in "${STOW_WHITELIST[@]}"; do
      if [[ $j == "$k" ]]; then
        files[i]=$j
        i=$(( i + 1 ))
      fi
    done
  done

  while true; do
    echo 'Would you like to stow the following packages? y/n'

    for i in "${files[@]}"; do
      echo "$i"
    done

    read -r input
    case "$input" in
      y) if [ "$D" = 'true' ]; then
           echo 'Dry run, skipping stow.'
         else
           echo 'Using stow to symlink packages.'

           for i in "${files[@]}"; do
             no_fold='false'
             for nf in "${NO_FOLDING_PACKAGES[@]}"; do
               if [[ $i == "$nf" ]]; then no_fold='true'; fi
             done

             if [ "$no_fold" = 'true' ]; then
               echo "stowing $i (--no-folding)"
               stow --no-folding "$i"
             else
               echo "stowing $i"
               stow "$i"
             fi
             done
         fi

         break
         ;;
      n) break ;;
      *) echo 'y or n' ;;
    esac
  done
fi

# Claude Code plugins and MCP servers live outside the stow tree — the CLI owns
# those directories — so they are reinstalled from manifests instead.
while true; do
  echo ''
  echo 'Would you like to reinstall Claude Code plugins and MCP servers? y/n'
  read -r input
  case "$input" in
    y) plugin_script="$PWD/claude/.claude/scripts/install-plugins.sh"
       mcp_script="$PWD/claude/.claude/scripts/install-mcp-servers.sh"

       if ! command -v claude &> /dev/null; then
         echo 'claude CLI not found on PATH, skipping.'
       elif [ "$D" = 'true' ]; then
         "$plugin_script" -d
         "$mcp_script" -d || echo 'Some MCP servers were skipped, see above.'
       else
         "$plugin_script" || echo 'Some plugins failed to install, see above.'
         "$mcp_script" || echo 'Some MCP servers were skipped, see above.'
       fi
       break
       ;;
    n) break ;;
    *) echo 'y or n' ;;
  esac
done
