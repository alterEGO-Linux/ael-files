#!/usr/bin/env sh
# :----------------------------------------------------------------------- INFO
# :[~/.ael/shellutils/juice-shop]
# :author        : fantomH @alterEGO Linux
# :created       : 2023-08-01 19:55:12 UTC
# :updated       : 2024-09-16 10:32:28 UTC
# :description   : Run OWASP Juice Shop container.

juice-shop() {
    local name="JUICE_SHOP"
    local _url="http://localhost:3000"

    trap 'cleanup' EXIT

    cleanup() {
        echo
        read -rp "[?] Stop container ${name}? [y/N] " ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then
            docker stop "$name" >/dev/null 2>&1
            echo "[!] Container stopped."
        else
            echo "[!] Container left running."
        fi
    }

    if docker container inspect "$name" >/dev/null 2>&1; then
        docker start "$name"
    else
        docker run -d --name "$name" -p 3000:3000 bkimminich/juice-shop
    fi

    sleep 3

    "${BROWSER:-xdg-open}" "${_url}" >/dev/null 2>&1 &

    echo "[+] Press Ctrl+C to exit..."
    wait
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    juice-shop "$@"
fi

# juice-shop() {

    # if [[ $(command systemctl is-active docker.service) == 'inactive' ]]; then
        # sudo systemctl start docker.service
        # echo "[-] Starting docker.service ..."
    # fi

    # if [[ "${1}" == 'stop' ]]; then
        # echo "================================================================================"
        # echo "[+] juice-shop()"
        # echo "    Stoping OWASP Juice Shop container."
        # echo "================================================================================"
        # echo

        # command docker stop $(command docker ps \
                              # | command grep JUICE_SHOP \
                              # | command cut -d ' ' -f1)
        
        # echo "[!] Done."
        # sleep 1
    # else
        # echo "================================================================================"
        # echo "[+] juice-shop()"
        # echo "    Starting OWASP Juice Shop container."
        # echo "================================================================================"
        # echo

        # echo "[!] Use <juice-shop stop> when you are done."
        # sleep 2

        # if command docker ps --all | command grep -q "JUICE_SHOP"; then
            # command docker start JUICE_SHOP
            # while [ "$(docker inspect -f '{{.State.Running}}' JUICE_SHOP)" != "true" ]; do
                # sleep 1
            # done
            # sleep 5
            # $BROWSER "http://localhost:3000"
        # else
            # command docker run --name JUICE_SHOP -p 3000:3000 bkimminich/juice-shop &

            # while true; do
                # if command docker ps --all | command grep -q "JUICE_SHOP" 2>/dev/null; then
                    # break
                # else
                    # sleep 1
                # fi
            # done
            # while [ "$(command docker inspect -f '{{.State.Running}}' JUICE_SHOP)" != "true" ]; do
                # sleep 1
            # done
            # sleep 5
            # $BROWSER "http://localhost:3000"
        # fi
    # fi
    # }
