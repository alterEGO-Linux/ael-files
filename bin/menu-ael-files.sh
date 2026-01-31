#!/usr/bin/env bash
# ------------------------------------------------------------------------ INFO
# [/.ael/bin/menu-ael-files.sh]
# author        : Pascal Malouin (https://github.com/alterEGO-Linux)
# created       : 2025-02-21 14:44:41 UTC
# updated       : 2026-01-31 15:29:07 UTC
# description   : Opens AEL files.

# -------------------- [ colors ]
blue=$'\033[34m'
bold=$'\033[1m'
red=$'\033[31m'
reset=$'\033[0m'
yellow=$'\033[33m'

check_applications() {
    # --- Verify if check-applications.sh is on PATH.
    if command -v check-applications.sh >/dev/null 2>&1; then
        check-applications.sh "${@}"
   else
        for app in "${@}"; do
            if ! command -v $app >/dev/null 2>&1; then
                printf '%s\n' "${red}[!]${reset} ${app} is not installed."
                return 1
            fi
        done
    fi
}
check_applications rg fzf vim sed sort || exit 1

git_directory="${HOME}/.local/share/ael-files"

selection=$(rg --files --hidden --glob "!.git" "${git_directory}"            \
    | sed -e "s:${git_directory}::g"                                         \
    | sort                                                                   \
    | fzf --color=gutter:-1                                                  \
          --margin=4%                                                        \
          --border=none                                                      \
          --prompt="Select a file ❯ "                                        \
          --header=" "                                                       \
          --no-hscroll                                                       \
          --reverse                                                          \
          -i                                                                 \
          --exact                                                            \
          --tiebreak=begin                                                   \
          --no-info)

selection="${git_directory}${selection}"

if [[ -n "$selection" ]]; then
    vim "$selection"
else
    printf "%s\n" "${red}[info]${reset} Nothing selected."
fi
