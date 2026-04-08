#!/usr/bin/env bash
# ------------------------------------------------------------------------ INFO
# [/.ael/bin/ports]
# author        : Pascal Malouin (https://github.com/alterEGO-Linux)
# created       : 2023-08-04 02:11:08 UTC
# updated       : 2026-04-08 18:53:02 UTC
# description   : Displays open ports.

ports() {

    local __red=$'\033[31m'
    local __reset=$'\033[0m'
    
    trap 'unset -f check_applications; trap - RETURN' RETURN

    check_applications() {
      local __app
      for __app in "${@}"; do
          if ! command -v $__app >/dev/null 2>&1; then
                printf '%s\n' "${__red}[!]${__reset} ${__app} is not installed."
                return 1
            fi
        done
    }
    check_applications netstat || return 1

    if [[ $(command -v grc) ]]; then
        sudo grc netstat -tulanp
    else
        sudo netstat -tulanp
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    ports
fi
