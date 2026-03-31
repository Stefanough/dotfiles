#!/bin/bash
# alascheme — switch alacritty color theme on the fly
#
# Usage: alascheme <theme_name>
# Tab-completion is provided via _alascheme_completions below.
# No-ops gracefully on systems without alacritty config.

ALACRITTY_CONFIG="$HOME/.config/alacritty/alacritty.toml"
ALACRITTY_THEMES_DIR="$HOME/.config/alacritty/alacritty-theme/themes"

if [[ ! -f "$ALACRITTY_CONFIG" ]]; then
  return 0 2>/dev/null || exit 0
fi

_alascheme_detect_variant() {
  local theme_file="$1"
  local hex
  hex=$(grep "^background" "$theme_file" 2>/dev/null | head -1 | sed "s/.*['\"]\#\([0-9a-fA-F]*\)['\"].*/\1/")

  if [[ -z "$hex" ]]; then
    echo "unknown"
    return
  fi

  # Parse RGB and compute perceived brightness
  local r=$((16#${hex:0:2}))
  local g=$((16#${hex:2:2}))
  local b=$((16#${hex:4:2}))
  local luminance=$(( (r * 299 + g * 587 + b * 114) / 1000 ))

  if (( luminance > 128 )); then
    echo "light"
  else
    echo "dark"
  fi
}

_alascheme_update_tmux() {
  [[ -z "$TMUX" ]] && return

  if [[ "$TERM_THEME" == "light" ]]; then
    tmux set -g pane-active-border-style fg=colour57
    tmux set -g pane-border-format "┤#{?pane_active,#{?#{==:#{pane_current_command},ssh},#[fg=red]#{pane_title}#[default],#[fg=cyan]#{s|$HOME|~|:pane_current_path}#[default]},#[fg=colour246]#{?#{==:#{pane_current_command},ssh},#{pane_title},#{s|$HOME|~|:pane_current_path}}#[default]}├"
  else
    tmux set -g pane-active-border-style fg=colour141
    tmux set -g pane-border-format "┤#{?pane_active,#{?#{==:#{pane_current_command},ssh},#[fg=red]#{pane_title}#[default],#[fg=cyan]#{s|$HOME|~|:pane_current_path}#[default]},#[fg=colour243]#{?#{==:#{pane_current_command},ssh},#{pane_title},#{s|$HOME|~|:pane_current_path}}#[default]}├"
  fi
}

alascheme() {
  local theme="$1"

  if [[ -z "$theme" ]]; then
    # No argument — print current theme and variant
    local current
    current=$(grep '^import' "$ALACRITTY_CONFIG" 2>/dev/null | sed 's/.*themes\/\(.*\)\.toml.*/\1/')
    if [[ -n "$current" ]]; then
      echo "$current ($TERM_THEME)"
    else
      echo "unknown"
    fi
    return 0
  fi

  local theme_file="$ALACRITTY_THEMES_DIR/${theme}.toml"

  if [[ ! -f "$theme_file" ]]; then
    echo "alascheme: theme '$theme' not found" >&2
    echo "Available themes in: $ALACRITTY_THEMES_DIR" >&2
    return 1
  fi

  # Update alacritty config import line (macOS sed)
  if sed --version >/dev/null 2>&1; then
    sed -i "s|^import = .*|import = [\"~/.config/alacritty/alacritty-theme/themes/${theme}.toml\"]|" "$ALACRITTY_CONFIG"
  else
    sed -i '' "s|^import = .*|import = [\"~/.config/alacritty/alacritty-theme/themes/${theme}.toml\"]|" "$ALACRITTY_CONFIG"
  fi

  # Detect and export light/dark variant
  TERM_THEME=$(_alascheme_detect_variant "$theme_file")
  export TERM_THEME

  # Update bat theme to match
  if [[ "$TERM_THEME" == "light" ]]; then
    export BAT_THEME="Solarized (light)"
  else
    export BAT_THEME="Solarized (dark)"
  fi

  _alascheme_update_tmux

  echo "Switched to: $theme ($TERM_THEME)"
}

# Set TERM_THEME on shell startup from current alacritty config
_alascheme_init() {
  local current
  current=$(grep '^import' "$ALACRITTY_CONFIG" 2>/dev/null | sed 's/.*themes\/\(.*\)\.toml.*/\1/')
  if [[ -n "$current" ]]; then
    local theme_file="$ALACRITTY_THEMES_DIR/${current}.toml"
    if [[ -f "$theme_file" ]]; then
      TERM_THEME=$(_alascheme_detect_variant "$theme_file")
      export TERM_THEME
    fi
  fi
}
_alascheme_init

_alascheme_completions() {
  local cur="${COMP_WORDS[COMP_CWORD]}"

  if [[ -d "$ALACRITTY_THEMES_DIR" ]]; then
    local themes
    themes=$(find "$ALACRITTY_THEMES_DIR" -maxdepth 1 -name '*.toml' -exec basename {} .toml \; 2>/dev/null)
    COMPREPLY=( $(compgen -W "$themes" -- "$cur") )
  fi
}

complete -F _alascheme_completions alascheme
