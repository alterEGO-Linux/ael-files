#!/usr/bin/env bash
# ------------------------------------------------------------------------ INFO
# [/.ael/bin/systeminfo.sh]
# author        : Pascal Malouin (https://github.com/alterEGO-Linux)
# created       : 2026-01-31 23:38:29 UTC
# updated       : 2026-04-10 15:19:56 UTC
# description   : Gather system information.

set -euo pipefail

declare -A __ip_addresses
declare -A __sysinfo

file_safe_reader() {
    # --| Safe wrapper to avoid reading error, for example:
    # ..| cat: file.txt: Permission denied
    # ..| cat: file.txt: No such file or directory

    local __path="${1}"
    if [[ -r "${__path}" ]]; then
        cat "${__path}"
    else
        printf ""
    fi
}

json_escape() {
    local __s="$1"
    __s=${__s//\\/\\\\}
    __s=${__s//\"/\\\"}
    __s=${__s//$'\n'/\\n}
    __s=${__s//$'\r'/\\r}
    __s=${__s//$'\t'/\\t}
    printf '%s' "$__s"
}

jkv() {
    # --| "key":"value" with proper JSON quoting.
    local __k="$1" __v="$2"
    printf '"%s":"%s"' "$(json_escape "$__k")" "$(json_escape "$__v")"
}

get_ip_addresses() {

    local __iface
    local __ip
    while read -r __iface __ip; do
        __ip_addresses["$__iface"]="$__ip"
    done < <(
        ip -4 a | awk '/inet/ {print $NF, $2}'
    )

    __public=$(command host myip.opendns.com resolver1.opendns.com | command grep --color=never -oP '(?<=myip.opendns.com has address ).*$')
    __ip_addresses['public']="${__public}"

}

get_sysinfo() {

    __kernel="$(uname -s -r)"
    __sysinfo['kernel']="$__kernel"

    __distribution="$(grep -oP '^NAME="\K[^"]+' /etc/os-release)"
    __sysinfo['distribution']="${__distribution}"

    __hostname=$(hostname)
    __sysinfo['hostname']="${__hostname}"

    __vendor=$(file_safe_reader /sys/class/dmi/id/sys_vendor 2>/dev/null)
    __model=$(file_safe_reader /sys/class/dmi/id/product_name 2>/dev/null)
    __sysinfo['device']="${__vendor} / ${__model}"

    __bios_ver=$(file_safe_reader /sys/class/dmi/id/bios_version 2>/dev/null)
    __bios_date=$(file_safe_reader /sys/class/dmi/id/bios_date 2>/dev/null)
    __sysinfo['bios']="${__bios_ver} (${__bios_date})"

    if grep -qi microsoft /proc/version; then
        __sysinfo['virtualization']="WSL"
    elif grep -qi hypervisor /proc/cpuinfo; then
        __sysinfo['virtualization']="VM"
    else
        __sysinfo['virtualization']="N/A"
    fi
}

as_json() {

    printf '{'

    get_sysinfo

    printf '%s,' "$(jkv "hostname" "${__sysinfo['hostname']}")"
    printf '%s,' "$(jkv "distribution" "${__sysinfo['distribution']}")"
    printf '%s,' "$(jkv "kernel" "${__sysinfo['kernel']}")"
    printf '%s,' "$(jkv "virtualization" "${__sysinfo['virtualization']}")"

    printf '"hardware and firmware":{'
    printf '%s,' "$(jkv "device" "${__sysinfo['device']}")"
    printf '%s' "$(jkv "bios" "${__sysinfo['bios']}")"
    printf '},'

    get_ip_addresses

    local __iface
    printf '"ip addresses":{'
        for __iface in "${!__ip_addresses[@]}"; do
            if [[ ${__iface} != 'public' ]]; then
                printf '%s, ' "$(jkv "${__iface}" "${__ip_addresses[$__iface]}")"
            fi
        done
        for __iface in "${!__ip_addresses[@]}"; do
            if [[ ${__iface} = 'public' ]]; then
                printf '%s' "$(jkv "${__iface}" "${__ip_addresses[$__iface]}")"
            fi
        done
    printf '}'

    printf '}'

}

to_stdout() {
  get_sysinfo
  get_ip_addresses

  local __hostname="${__sysinfo['hostname']}"
  local __distribution="${__sysinfo['distribution']}"
  local __kernel="${__sysinfo['kernel']}"
  local __virtualization="${__sysinfo['virtualization']}"
  local __device="${__sysinfo['device']}"
  local __bios="${__sysinfo['bios']}"

  # --- Header.
  printf '%s\n' "────────────────────────────────────────────────────────"
  printf ' %s\n' "System Info"
  printf '%s\n' "────────────────────────────────────────────────────────"

  printf '  %-18s %s\n' "Hostname:" "${__hostname}"
  printf '  %-18s %s\n' "Distribution:" "${__distribution}"
  printf '  %-18s %s\n' "Kernel:" "${__kernel}"
  printf '  %-18s %s\n' "Virtualization:" "${__virtualization}"

  printf '\n'
  printf ' %s\n' "Hardware / Firmware"
  printf '%s\n' "────────────────────────────────────────────────────────"
  printf '  %-18s %s\n' "Device:" "${__device}"
  printf '  %-18s %s\n' "BIOS:" "${__bios}"

  printf '\n'
  printf ' %s\n' "IP Addresses"
  printf '%s\n' "────────────────────────────────────────────────────────"

  local __iface
  for __iface in $(printf '%s\n' "${!__ip_addresses[@]}" | sort); do
    printf '  %-18s %s\n' "${__iface}:" "${__ip_addresses[$__iface]}"
  done
}

case "${@}" in

    --json)
        as_json
        ;;
    *)
        to_stdout
        ;;

esac
