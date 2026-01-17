#! /usr/bin/env bash
# ------------------------------------------------------------------------ INFO
# [/.ael/bin/check-applications.sh]
# author        : Pascal Malouin @https://github.com/alterEGO-Linux
# created       : 2026-01-09 11:08:55 UTC
# updated       : 2026-01-17 11:15:44 UTC
# description   : Check applications' availability.

__blue=$'\033[34m'
__red=$'\033[31m'
__reset=$'\033[0m'
__apps=("$@")
__missing=()

for app in "${__apps[@]}"; do
    if ! command -v "${app}" > /dev/null 2>&1; then
        __missing+=("${app}")
    fi
done

if (( ${#__missing[@]} > 0 )); then

    for app in "${__missing[@]}"; do
        printf '%s\n' "${__red}[!]${__reset} ${app} is not installed."

        __converter="convert-toml-json.py"
        __packages="${__AEL_DATA}/ael-packages.toml"
        if command -v $__converter > /dev/null 2>&1 && [ -f "${__packages}"  ]; then
            mapfile -t pkgs < <(
                python "$__converter" "$__packages" |
                jq -r --arg app "$app" '
                  to_entries[]
                  | select( ((.value.included_app? // []) | any(.[]; endswith("/" + $app))) )
                  | .key
                '
            )
        else
            mapfile -t pkgs < <(
                pacman -F -- "/usr/bin/${app}" 2>/dev/null | sort -u
            )
        fi

        # --- fallback, search by name.
        if (( ${#pkgs[@]} == 0 )); then
            mapfile -t pkgs < <(
                pacman -F -- "${app}" 2>/dev/null | sort -u
            )
        fi

        if (( ${#pkgs[@]} > 0 )); then
            printf '%s[*]%s %s is part of %s%s%s\n' "${__blue}" "${__reset}" "${app}" "${__blue}" "${pkgs[0]}" "${__reset}"
        else
            printf '%s\n' "${__red}[!]${__reset} Could not find the package owning ${app}."
        fi
    done
exit 1
fi
