# Source this file from .bashrc or .zshrc to let awsp update the current shell.

awsp() {
  local action="${1:-select}" shell_updates
  case "$action" in
    select|use|clear|logout)
      if shell_updates=$(command awsp --shell-output "$@"); then
        [[ -z "$shell_updates" ]] || eval "$shell_updates"
      else
        return $?
      fi
      ;;
    *) command awsp "$@" ;;
  esac
}
