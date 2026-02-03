#! /usr/bin/env sh
# ------------------------------------------------------------------------ INFO
# [/.ael/bin/systeminfo.sh]
# author        : Pascal Malouin (https://github.com/alterEGO-Linux)
# created       : 2026-01-31 23:38:29 UTC
# updated       : 2026-02-03 12:36:32 UTC
# description   : Gather system information.

set -euo pipefail

declare -A ip_addresses
declare -A sysinfo

file_safe_reader() {
    local path="${1}"
    if [[ -r "${path}" ]]; then
        cat "${path}"
    else
        printf ""
    fi
}

json_escape() {
    local s="$1"
    s=${s//\\/\\\\}
    s=${s//\"/\\\"}
    s=${s//$'\n'/\\n}
    s=${s//$'\r'/\\r}
    s=${s//$'\t'/\\t}
    printf '%s' "$s"
}

jkv() {
    # --- "key":"value" with proper JSON quoting.
    local k="$1" v="$2"
    printf '"%s":"%s"' "$(json_escape "$k")" "$(json_escape "$v")"
}

get_ip_addresses() {

    while read -r iface ip; do
        ip_addresses["$iface"]="$ip"
    done < <(
        ip -4 a | awk '/inet/ {print $NF, $2}'
    )

    public=$(command host myip.opendns.com resolver1.opendns.com | command grep --color=never -oP '(?<=myip.opendns.com has address ).*$')
    ip_addresses['public']="${public}"

}

get_sysinfo() {

    kernel="$(uname -s -r)"
    sysinfo['kernel']="$kernel"

    distribution="$(grep -oP '^NAME="\K[^"]+' /etc/os-release)"
    sysinfo['distribution']="${distribution}"

    hostname=$(hostname)
    sysinfo['hostname']="${hostname}"

    vendor=$(file_safe_reader /sys/class/dmi/id/sys_vendor 2>/dev/null)
    model=$(file_safe_reader /sys/class/dmi/id/product_name 2>/dev/null)
    sysinfo['device']="${vendor} / $model"

    bios_ver=$(file_safe_reader /sys/class/dmi/id/bios_version 2>/dev/null)
    bios_date=$(file_safe_reader /sys/class/dmi/id/bios_date 2>/dev/null)
    sysinfo['bios']="${bios_ver} (${bios_date})"

    if grep -qi microsoft /proc/version; then
        sysinfo['virtualization']="WSL"
    elif grep -qi hypervisor /proc/cpuinfo; then
        sysinfo['virtualization']="VM"
    else
        sysinfo['virtualization']="N/A"
    fi
}

as_json() {

    printf '{'

    get_sysinfo

    printf '%s,' "$(jkv "hostname" "${sysinfo['hostname']}")"
    printf '%s,' "$(jkv "distribution" "${sysinfo['distribution']}")"
    printf '%s,' "$(jkv "kernel" "${sysinfo['kernel']}")"
    printf '%s,' "$(jkv "virtualization" "${sysinfo['virtualization']}")"

    printf '"hardware and firmware":{'
    printf '%s,' "$(jkv "device" "${sysinfo['device']}")"
    printf '%s' "$(jkv "bios" "${sysinfo['bios']}")"
    printf '},'

    get_ip_addresses

    printf '"ip adresses":{'
        for iface in "${!ip_addresses[@]}"; do
            if [[ ${iface} != 'public' ]]; then
                printf '%s, ' "$(jkv "${iface}" "${ip_addresses[$iface]}")"
            fi
        done
        for iface in "${!ip_addresses[@]}"; do
            if [[ ${iface} = 'public' ]]; then
                printf '%s' "$(jkv "${iface}" "${ip_addresses[$iface]}")"
            fi
        done
    printf '}'

    printf '}'

}

to_stdout() {
  get_sysinfo
  get_ip_addresses

  local hostname="${sysinfo['hostname']}"
  local distribution="${sysinfo['distribution']}"
  local kernel="${sysinfo['kernel']}"
  local virtualization="${sysinfo['virtualization']}"
  local device="${sysinfo['device']}"
  local bios="${sysinfo['bios']}"

  # --- Header.
  printf '%s\n' "────────────────────────────────────────────────────────"
  printf ' %s\n' "System Info"
  printf '%s\n' "────────────────────────────────────────────────────────"

  printf '  %-18s %s\n' "Hostname:" "${hostname}"
  printf '  %-18s %s\n' "Distribution:" "${distribution}"
  printf '  %-18s %s\n' "Kernel:" "${kernel}"
  printf '  %-18s %s\n' "Virtualization:" "${virtualization}"

  printf '\n'
  printf ' %s\n' "Hardware / Firmware"
  printf '%s\n' "────────────────────────────────────────────────────────"
  printf '  %-18s %s\n' "Device:" "${device}"
  printf '  %-18s %s\n' "BIOS:" "${bios}"

  printf '\n'
  printf ' %s\n' "IP Addresses"
  printf '%s\n' "────────────────────────────────────────────────────────"

  local iface
  for iface in $(printf '%s\n' "${!ip_addresses[@]}" | sort); do
    printf '  %-18s %s\n' "${iface}:" "${ip_addresses[$iface]}"
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
