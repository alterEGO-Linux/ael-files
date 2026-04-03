#!/usr/bin/env bash
# ------------------------------------------------------------------------ INFO
# [/.ael/bin/deep-scan.sh]
# author        : Pascal Malouin (https://github.com/alterEGO-Linux)
# created       : 2026-04-03 23:33:30 UTC
# updated       : 2026-04-03 23:33:30 UTC
# description   : Scans IP with rustscan and nmap.

deep-scan() {

    local __blue=$'\033[34m'
    local __red=$'\033[31m'
    local __reset=$'\033[0m'

    trap 'unset -f check_applications usage; trap - RETURN' RETURN

    check_applications() {
      local __app
      for __app in "${@}"; do
          if ! command -v $__app >/dev/null 2>&1; then
                printf '%s\n' "${__red}[!]${__reset} ${__app} is not installed."
                return 1
            fi
        done
    }
    check_applications rustscan sudo nmap || return 1

    usage() {
        cat <<EOF
================================================================================
[+] deep-scan - Scans IP with rustscan and nmap.
================================================================================
Usage:
  deep-scan <Target> | [-h|--help]

Runs RustScan to find the available ports and passes the ports to Nmap.

Options:
  -h, --help    Display this help message.

Examples:
  deep-scan 192.168.1.1
  deep-scan localhost
================================================================================
EOF
    }

    # --- setting IP value.
    local __ip
    __ip="${1:-127.0.0.1}"
    [[ "$__ip" == "localhost" ]] && __ip="127.0.0.1"

    # --- show help and ignore other arguments.
    local __i
    for __i in "${@}"; do
        if [[ "${__i}" == "-h" || "${__i}" == "--help" ]]; then
            usage
            return 1
        fi
    done

    # --- too many arguments.
    if [[ $# -gt 1 ]]; then
        printf '%s\n' "${__red}[!]${__reset} Too many arguments."
        usage
        return 1
    fi

    # --- rustscan.
    printf '%s\n' "${__blue}[*]${__reset} Running Rustscan to find open ports."

    local __ports=$(rustscan -a "$__ip" --ulimit 5000 --batch-size 2000 --greppable | grep -oP '\[\K[0-9,]+(?=\])')

    # --- nmap.
    if [[ -n "${__ports}" ]]; then
        printf '%s\n' "${__blue}[*]${__reset} Found ${__ports}."
        printf '%s\n' "${__blue}[*]${__reset} Running Nmap."

        # --- check grc availability.
        local __nmap
        if command -v grc >/dev/null 2>&1; then
            __nmap=(grc nmap)
        else
            __nmap=(nmap)
        fi 

        sudo "${__nmap[@]}" -sV -O -sC --traceroute "${__ip}" -p "${__ports}"
        return 0
    else
        printf '%s\n' "${__red}[!]${__reset} Found nothing."
        return 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    deep-scan "$@"
fi
