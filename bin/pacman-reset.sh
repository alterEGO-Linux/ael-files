#!/usr/bin/env bash
# ------------------------------------------------------------------------ INFO
# [/.ael/bin/pacman-reset]
# author        : Pascal Malouin (https://github.com/alterEGO-Linux)
# created       : 2023-10-20 10:46:22 UTC
# updated       : 2026-04-09 00:38:24 UTC
# description   : Re-initialize pacman sync, mirrorlist and keyring.

pacman-reset() {

    local __blue=$'\033[34m'
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
    check_applications curl sudo pacman sed || return 1

    printf '%s\n' "${BLUE}[+]${RESET} pacmn-reset - Re-initializing Pacman."

    printf '%s\n' "${BLUE}[*]${RESET} Removing sync file."
    sudo $(command -v rm) -rf /var/lib/pacman/sync

    printf '%s\n' "${BLUE}[*]${RESET} Fetching Pacman mirrorlist."
    sudo $(command -v curl) -o /etc/pacman.d/mirrorlist 'https://archlinux.org/mirrorlist/?country=US&protocol=http&protocol=https&ip_version=4'

    printf '%s\n' "${BLUE}[*]${RESET} Fixing Pacman mirrorlist."
    sudo $(command -v sed) -i -e 's/\#Server/Server/g' /etc/pacman.d/mirrorlist

    printf '%s\n' "${BLUE}[*]${RESET} Updating archlinux-keyring."
    sudo $(command -v pacman) -Syy --noconfirm archlinux-keyring

    printf '%s\n' "${BLUE}[*]${RESET} All done!"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    pacman-reset
fi
