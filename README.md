<table>
<tr>
<td><img src="https://github.com/Bedatty-Engineering.png" alt="Bedatty Engineering" width="72" /></td>
<td><h1>awsp</h1><p>An AWS CLI profile switcher with interactive selection, SSO login, and shell integration.</p></td>
</tr>
</table>

`awsp` manages configured [AWS CLI](https://docs.aws.amazon.com/cli/)
profiles from a terminal. It supports profile selection, SSO login/logout,
credential status, and region environment variables.

## Contents

- [Features](#features)
- [Requirements](#requirements)
- [Install](#install)
- [Shell integration](#shell-integration)
- [Update](#update)
- [Usage](#usage)
- [Profiles and SSO](#profiles-and-sso)
- [Uninstall](#uninstall)
- [Privacy](#privacy)
- [License](#license)

## Features

- Select AWS profiles interactively with `fzf` or switch by name.
- Set `AWS_PROFILE`, `AWS_REGION`, and `AWS_DEFAULT_REGION` in the current shell.
- Check authentication through AWS STS.
- Start an SSO login for a profile or log out of all SSO sessions.
- Install, update, and uninstall the command independently of dotfiles.

## Requirements

| Dependency | Needed for |
| --- | --- |
| Bash 3.2 or later | Running `awsp` and the install scripts |
| AWS CLI v2 | Profile commands and SSO |
| [fzf](https://github.com/junegunn/fzf) | Interactive profile picker |
| `curl` | Remote install and update scripts |

## Install

Install the latest version directly:

```sh
curl -fsSL https://raw.githubusercontent.com/Bedatty-Engineering/awsp/main/scripts/install.sh | bash
```

The installer places `awsp` in `~/.local/bin` and the shell integration in
`~/.local/share/awsp`. If needed, set custom directories:

```sh
curl -fsSL https://raw.githubusercontent.com/Bedatty-Engineering/awsp/main/scripts/install.sh | AWSP_INSTALL_DIR="$HOME/bin" AWSP_DATA_DIR="$HOME/.local/share/awsp" bash
```

You can also clone the repository and install from the checkout:

```sh
git clone https://github.com/Bedatty-Engineering/awsp.git
cd awsp
./scripts/install.sh
```

## Shell integration

A standalone process cannot change environment variables in its parent shell.
The installer includes a shell function that forwards state-changing commands
to `awsp` and applies its output to the current shell. Add this line to
`~/.zshrc` or `~/.bashrc` after ensuring `~/.local/bin` is on `PATH`:

```sh
source "$HOME/.local/share/awsp/awsp.sh"
```

Then restart the shell or source the file once. `awsp use`, the interactive
picker, `awsp clear`, and `awsp logout` will update the current terminal.

Without the integration, evaluate the shell commands printed by the executable:

```sh
eval "$(awsp use my-profile)"
eval "$(awsp)"  # interactive selection
```

## Update

Update both the executable and shell integration from a checkout:

```sh
./scripts/update.sh
```

Or run the updater from GitHub:

```sh
curl -fsSL https://raw.githubusercontent.com/Bedatty-Engineering/awsp/main/scripts/update.sh | bash
```

The updater requires an existing `awsp` installation, downloads both files,
checks their shell syntax, and replaces only changed files. Set
`AWSP_INSTALL_DIR` or `AWSP_DATA_DIR` when using custom locations.

## Usage

```sh
awsp                          # Choose a profile with fzf
awsp use <profile>            # Switch profiles
awsp list                     # List configured profiles
awsp status                   # Show profile and STS authentication status
awsp login [profile]          # Start SSO login (defaults to AWS_PROFILE)
awsp logout                   # Log out of all AWS SSO sessions
awsp clear                    # Clear profile and region variables
awsp help                     # Show command help
```

## Profiles and SSO

`awsp` reads profiles from the AWS CLI configuration in `~/.aws/config` and
credentials files. It does not create or edit AWS credentials. Configure
profiles with `aws configure`, `aws configure sso`, or your existing
configuration management.

Switching profiles checks AWS STS. If the selected profile uses SSO and its
session is missing or expired, `awsp` starts `aws sso login` for that profile.
The region from the profile is exported as both `AWS_REGION` and
`AWS_DEFAULT_REGION`. Switching to a profile without a configured region clears
those variables to avoid retaining the previous profile's region.

## Uninstall

Remove the command and shell integration from a checkout with:

```sh
./scripts/uninstall.sh
```

The remote uninstaller is also available:

```sh
curl -fsSL https://raw.githubusercontent.com/Bedatty-Engineering/awsp/main/scripts/uninstall.sh | bash
```

If you added the `source` line to a shell startup file, remove that line too.
The uninstall script does not delete AWS configuration, credentials, or SSO
cache data.

## Privacy

The repository contains no account names, AWS account identifiers,
credentials, or machine-specific paths. AWS configuration and credential files
remain under the user's control and are not modified by the installer.

## License

MIT. See [LICENSE](LICENSE).
