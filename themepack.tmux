#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

get-tmux-option() {
  local option value default
  option="$1"
  default="$2"
  value="$(tmux show-option -gqv "$option")"

  if [ -n "$value" ]; then
    echo "$value"
  else
    echo "$default"
  fi
}

main() {
  local theme
  theme="$(get-tmux-option "@themepack" "basic")"
  # Ensure theme ends in tmuxtheme
  theme="${theme/.tmuxtheme/}.tmuxtheme"

  if [ -f "$CURRENT_DIR/${theme}" ]; then
    tmux source-file "$CURRENT_DIR/${theme}"
  else
    printf "Cannot find theme %s.\n" "${theme}"
    exit 1
  fi
}

main "$@"
