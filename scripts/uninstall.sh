#!/usr/bin/env bash
# Remove awsp and its shell integration.

set -euo pipefail

install_dir="${AWSP_INSTALL_DIR:-${1:-$HOME/.local/bin}}"
data_dir="${AWSP_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/awsp}"
target="$install_dir/awsp"
integration_target="$data_dir/awsp.sh"

if [[ -f "$target" || -L "$target" ]]; then
  rm -f "$target"
  printf 'Removed %s\n' "$target"
else
  printf 'awsp is not installed at %s\n' "$target"
fi

if [[ -f "$integration_target" || -L "$integration_target" ]]; then
  rm -f "$integration_target"
  printf 'Removed %s\n' "$integration_target"
else
  printf 'Shell integration is not installed at %s\n' "$integration_target"
fi
