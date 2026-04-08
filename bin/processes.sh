#!/usr/bin/env bash
# ------------------------------------------------------------------------ INFO
# [/.ael/bin/processes.sh]
# author        : Pascal Malouin (https://github.com/alterEGO-Linux)
# created       : 2023-08-02 00:51:54 UTC
# updated       : 2026-04-08 16:05:50 UTC
# description   : Show processes.

processes() {

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
    check_applications ps || return 1

    if [[ $(command -v grc) ]]; then
        command grc ps aux
    else
        command ps aux
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    processes
fi
