#!/bin/sh

################################################################################
# Interactive-ish installer for HomeBrew and packages, setup.
#
# options:
#   -d dry-run. Defaults to false.
#   -s attempt to execute stow Defaults to false.
#
# HomeBrew binary is installed to /opt/homebrew/bin/brew based on "which brew"
#
# TODO:
#   set faster scroll speed for mac if possible
#   set default shell to bash
#   check for already stowed packages (necessary?)
#   Is it dangerous to print command names as part of the stow prompt?
################################################################################

readonly HOMEBREW_INSTALL_LOCATION='/opt/homebrew/bin/brew'
readonly STOW_WHITELIST=(MenuMeters VSCode alacritty bash ctags git npm ripgrep shellcheck tmux vim)


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
         brew bundle --verbose --no-lock --file="packages.personal.Brewfile"
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
             echo "stowing $i"
             stow "$i"
             done
         fi

         break
         ;;
      n) break ;;
      *) echo 'y or n' ;;
    esac
  done
fi
