#!/usr/bin/env bash
# ------------------------------------------------------------------------ INFO
# [/.ael/bin/virtual-boxes.sh]
# author        : Pascal Malouin (https://github.com/alterEGO-Linux)
# created       : 2025-02-18 20:57:09 UTC
# updated       : 2026-01-31 14:06:23 UTC
# description   : Virtualbox VMs launcher.

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
check_applications vboxmanage awk fzf || exit 1

selection=$(vboxmanage list vms | awk -F\" '{print $2, $3}'                  \
    | fzf --color=gutter:-1                                                  \
          --margin=4%                                                        \
          --border=none                                                      \
          --prompt="START VM ❯ "                                             \
          --header=" "                                                       \
          --no-hscroll                                                       \
          --reverse                                                          \
          -i                                                                 \
          --exact                                                            \
          --tiebreak=begin                                                   \
          --no-info)

# --- Extract the UUID (removes curly braces).
vm_uuid=$(echo "$selection" | awk '{gsub(/[{}]/, "", $2); print $2}')

# --- Start the selected VM.
if [[ -n "$vm_uuid" ]]; then
    printf "%s\n" "${blue}[action]${reset} Starting VM: ${vm_uuid}"
    vboxmanage startvm "$vm_uuid"
else
    printf "%s\n" "${red}[info]${reset} No VM selected."
fi
