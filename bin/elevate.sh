#!/usr/bin/env bash
# ------------------------------------------------------------------------ INFO
# [/.ael/bin/elevate.sh]
# author        : Pascal Malouin (https://github.com/alterEGO-Linux)
# created       : 2023-08-02 00:10:38 UTC
# updated       : 2026-04-07 11:15:26 UTC
# description   : Repeats last command with sudo, if forgotten.

elevate() {

    local __args=("${@}")
    local __arg
    local __blue=$'\033[34m'
    local __red=$'\033[31m'
    local __reset=$'\033[0m'

    trap 'unset -f usage check_applications; trap - RETURN' RETURN

    check_applications() {
      local __app
      for __app in "${@}"; do
          if ! command -v $__app >/dev/null 2>&1; then
                printf '%s\n' "${__red}[!]${__reset} ${__app} is not installed."
                return 1
            fi
        done
    }
    check_applications bash sudo || return 1

    usage() {
        cat <<EOF
================================================================================
[+] elevate - Repeats last command with sudo, if forgotten.
================================================================================
Usage:
  elevate [--interactive][--help]

<elevate> runs sudo \$(history -p !!), which allows to run the last command 
with elevated privileges.

Options:
  -i, --interactive    Prompt for confirmation.
  -h, --help           Display this help message.

IMPORTANT:
  This script must be sourced, otherwise history won't act as intented.
================================================================================
EOF
    }

    local __command=$(history -p !!)

    # --- help
    for __arg in "${__args[@]}"; do
        if [ "${__arg}" == '-h' ] || [ "${__arg}" == '--help' ]; then
            usage
            return 0
        fi
    done

    # --- Interactive.
    # ... Will exit in non-interactive context.
    
    local __input
    for __arg in "${__args[@]}"; do
        if [[ "${__arg}" == '-i' ]] || [[ "${__arg}" == '--interactive' ]]; then
            if [[ ! -t 0 ]]; then
                printf '%s\n' "${__red}[!]${__reset} No interactive terminal available for confirmation prompt." >&2
                return 1
            fi
            printf "${__blue}[?]${__reset} Are you sure you want to proceed? [y/N] "
            read -r __input
                if [[ "${__input}" =~ ^([yY][eE][sS]|[yY])$ ]]; then
                    sudo bash -c "${__command}"
                    return 0
                else
                    printf '%s\n' "${__red}[!]${__reset} Aborting running '${__command}' with elevated privileges."
                    return 1
                fi
        fi
    done

    sudo bash -c "${__command}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    usage --help
fi
