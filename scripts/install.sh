#!/usr/bin/env bash
# Install awsp and its shell integration from a checkout or GitHub.

set -euo pipefail

readonly raw_base='https://raw.githubusercontent.com/Bedatty-Engineering/awsp/main'
install_dir="${AWSP_INSTALL_DIR:-${1:-$HOME/.local/bin}}"
data_dir="${AWSP_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/awsp}"
script_source="${BASH_SOURCE[0]:-}"
repo_root=''
if [[ -n "$script_source" && -f "$script_source" ]]; then
  script_dir=$(cd "$(dirname "$script_source")" && pwd)
  repo_root="$script_dir/.."
fi
temporary_binary=''
temporary_integration=''
trap '[[ -z "$temporary_binary" ]] || rm -f "$temporary_binary"; [[ -z "$temporary_integration" ]] || rm -f "$temporary_integration"' EXIT

mkdir -p "$install_dir" "$data_dir"
temporary_binary=$(mktemp "$install_dir/.awsp-install.XXXXXX")
temporary_integration=$(mktemp "$data_dir/.awsp-install.XXXXXX")

if [[ -f "$repo_root/awsp" && -f "$repo_root/shell/awsp.sh" ]]; then
  cp "$repo_root/awsp" "$temporary_binary"
  cp "$repo_root/shell/awsp.sh" "$temporary_integration"
else
  command -v curl >/dev/null 2>&1 || {
    printf 'awsp installer: curl is required to download awsp.\n' >&2
    exit 1
  }
  curl -fsSL "$raw_base/awsp" -o "$temporary_binary"
  curl -fsSL "$raw_base/shell/awsp.sh" -o "$temporary_integration"
fi

if [[ ! -s "$temporary_binary" ]] || ! head -n 1 "$temporary_binary" | grep -q '^#!/usr/bin/env bash$'; then
  printf 'awsp installer: downloaded command is not a valid awsp executable.\n' >&2
  exit 1
fi
bash -n "$temporary_binary"
bash -n "$temporary_integration"

chmod 755 "$temporary_binary"
chmod 644 "$temporary_integration"
mv -f "$temporary_binary" "$install_dir/awsp"
temporary_binary=''
mv -f "$temporary_integration" "$data_dir/awsp.sh"
temporary_integration=''

printf 'Installed awsp to %s/awsp\n' "$install_dir"
printf 'Installed shell integration to %s/awsp.sh\n' "$data_dir"
case ":${PATH}:" in
  *":${install_dir}:"*) ;;
  *) printf 'Add this directory to PATH: %s\n' "$install_dir" ;;
esac
printf 'Add this line to ~/.bashrc or ~/.zshrc to enable shell profile switching:\n  source "%s/awsp.sh"\n' "$data_dir"
