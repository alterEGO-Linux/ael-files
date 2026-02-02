#! /usr/bin/env sh
# ------------------------------------------------------------------------ INFO
# [/.ael/bin/systeminfo.sh]
# author        : Pascal Malouin (https://github.com/alterEGO-Linux)
# created       : 2026-01-31 23:38:29 UTC
# updated       : 2026-01-31 23:38:29 UTC
# description   : Gather system information.

declare -A ip_addresses
declare -A sysinfo

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

    vendor=$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null)
    model=$(cat /sys/class/dmi/id/product_name 2>/dev/null)
    sysinfo['device']="${vendor} / $model"

    bios_ver=$(cat /sys/class/dmi/id/bios_version 2>/dev/null)
    bios_date=$(cat /sys/class/dmi/id/bios_date 2>/dev/null)
    sysinfo['bios']="${bios_ver} (${bios_date})"

}

get_ip_addresses

for iface in "${!ip_addresses[@]}"; do

    echo "    ($iface) ${ip_addresses[$iface]}"

done

get_sysinfo

for x in "${!sysinfo[@]}"; do
    echo "    $x -> ${sysinfo[$x]}"
done

