#!/usr/bin/env bash
# Update awsp and its shell integration from the latest main version.

set -euo pipefail

readonly raw_base='https://raw.githubusercontent.com/Bedatty-Engineering/awsp/main'
install_dir="${AWSP_INSTALL_DIR:-${1:-$HOME/.local/bin}}"
data_dir="${AWSP_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/awsp}"
target="$install_dir/awsp"
integration_target="$data_dir/awsp.sh"
temporary_binary=''
temporary_integration=''
trap '[[ -z "$temporary_binary" ]] || rm -f "$temporary_binary"; [[ -z "$temporary_integration" ]] || rm -f "$temporary_integration"' EXIT

if [[ ! -x "$target" ]]; then
  printf 'awsp updater: no executable found at %s\n' "$target" >&2
  printf 'Install awsp first with scripts/install.sh.\n' >&2
  exit 1
fi
command -v curl >/dev/null 2>&1 || {
  printf 'awsp updater: curl is required to download the latest version.\n' >&2
  exit 1
}

mkdir -p "$data_dir"
temporary_binary=$(mktemp "$install_dir/.awsp-update.XXXXXX")
temporary_integration=$(mktemp "$data_dir/.awsp-update.XXXXXX")
curl -fsSL "$raw_base/awsp" -o "$temporary_binary"
curl -fsSL "$raw_base/shell/awsp.sh" -o "$temporary_integration"

if [[ ! -s "$temporary_binary" ]] || ! head -n 1 "$temporary_binary" | grep -q '^#!/usr/bin/env bash$'; then
  printf 'awsp updater: downloaded command is not a valid awsp executable.\n' >&2
  exit 1
fi
bash -n "$temporary_binary"
bash -n "$temporary_integration"

if cmp -s "$target" "$temporary_binary"; then
  printf 'awsp command is already up to date.\n'
  rm -f "$temporary_binary"
  temporary_binary=''
else
  chmod 755 "$temporary_binary"
  mv -f "$temporary_binary" "$target"
  temporary_binary=''
  printf 'Updated awsp at %s\n' "$target"
fi

if [[ -f "$integration_target" ]] && cmp -s "$integration_target" "$temporary_integration"; then
  printf 'Shell integration is already up to date.\n'
  rm -f "$temporary_integration"
  temporary_integration=''
else
  chmod 644 "$temporary_integration"
  mv -f "$temporary_integration" "$integration_target"
  temporary_integration=''
  printf 'Updated shell integration at %s\n' "$integration_target"
fi
