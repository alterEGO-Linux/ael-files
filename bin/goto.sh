#!/usr/bin/env bash
# ------------------------------------------------------------------------ INFO
# [/.ael/bin/goto.sh]
# author        : Pascal Malouin (https://github.com/alterEGO-Linux)
# created       : 2026-04-07 20:48:33 UTC
# updated       : 2026-04-07 20:48:33 UTC
# description   : Simple directory bookmarks system.

# --| ref. <https://threkk.medium.com/how-to-use-bookmarks-in-bash-zsh-6b8074e40774>
# ..| ref. <https://twitter.com/mattn_jp/status/1434192554036137995>

GOTODIR="${HOME}/.ael/.goto/"
[[ ! -d "${GOTODIR}" ]] && mkdir -p "${GOTODIR}"
export CDPATH=".:$GOTODIR:/"

goto() {

    local IFS=$'\n'
    local __blue=$'\033[34m'
    local __red=$'\033[31m'
    local __reset=$'\033[0m'

    trap 'unset -f usage; trap - RETURN' RETURN

    usage() {
        cat <<EOF
================================================================================
[+] goto - Simple directory bookmarks system.
================================================================================
Usage:
  goto [bookmark|--add PATH BOOKMARK|--help|--list|--remove BOOKMARK]

Examples:
  goto @app            # :: Navigate to the @app bookmark.

Options:
  --add PATH BOOKMARK  Add a new bookmark for the specified path.
  --help               Display this help message.
  --list               List bookmarks.
  --remove BOOKMARK    Remove a bookmark.

IMPORTANT:
  This script must be sourced.
================================================================================
EOF
    }

    # --| help
    local __args=("$@")
    local __arg
    for __arg in "${__args[@]}"; do
        if [ "$__arg" == '-h' ] || [ "$__arg" == '--help' ]; then
            usage
            return 0
        fi
    done

    # --| list
    for __arg in "${__args[@]}"; do
        if [ "$__arg" == '-l' ] || [ "$__arg" == '--list' ]; then
            usage
            echo
            find "${GOTODIR}" -maxdepth 1 -type l | while read -r link; do
                local __target=$(readlink -f "${link}")
                printf "%-15s -> %s\n" "$(basename "${link}")" "${__target}"
            done
            return 0
        fi
    done

    # --| add
    local i
    for i in "${!__args[@]}"; do
        if [[ "${__args[i]}" == "-a" ]] || [[ "${__args[i]}" == "--add" ]]; then
            if [[ -n "${__args[i+1]}" && -n "${__args[i+2]}" ]]; then
                ln -s "$(realpath "${__args[i+1]}")" "${GOTODIR}/${__args[i+2]}"
                printf '%s\n' "${__blue}[*]${__reset} goto - Bookmark '${__args[i+2]}' added for path '${__args[i+1]}'."
                return 0
            else
                usage
                echo
                printf '%s\n' "${__red}[!]${__reset} Error: Both PATH and BOOKMARK are required."
                return 1
            fi
        fi
    done

    # --| remove
    for i in "${!__args[@]}"; do
        if [[ "${__args[i]}" == "-r" ]] || [[ "${__args[i]}" == "--remove" ]]; then
            if [[ -n "${__args[i+1]}" ]]; then
                __target="${GOTODIR}/${__args[i+1]}"
                if [[ -L "$__target" ]]; then
                    local __input
                    read -p "${__blue}[?]${__reset} Are you sure your want to delete this bookmark? [y/N] " __input
                        if [[ "${__input}" =~ ^([yY][eE][sS]|[yY])$ ]]; then
                            rm -f "$__target"
                            printf '%s\n' "${__blue}[*]${__reset} goto - Bookmark '${__args[i+1]}' removed."
                            return 0
                        else
                            printf '%s\n' "${__red}[!]${__reset} goto - Abording deletion!"
                            return 0
                        fi
                else
                    usage
                    echo
                    printf '%s\n' "${__red}[!]${__reset} Error: Bookmark '${__args[i+1]}' not found."
                    return 1
                fi
            else
                usage
                echo
                printf '%s\n' "${__red}[!]${__reset} Error: BOOKMARK is required."
                return 1
            fi
        fi
    done

    # --| goto
    if [[ "${#__args[@]}" -eq 0 ]]; then
        usage
        return 1
    elif [[ $# -ne 1 ]]; then
        usage
        echo
        printf '%s\n' "${__red}[!]${__reset} Error: Too many arguments."
        return 1
    else
        if [[ -e "${GOTODIR}/$1" ]]; then
            cd -P "${GOTODIR}/$1"
            return 0
        else
            usage
            echo
            printf '%s\n' "${__red}[!]${__reset} Error: '$1' is not a valid bookmark."
            return 1
        fi
    fi
}

_goto_complete() {
    local IFS=$'\n'
    COMPREPLY=( $(compgen -W "$(find "${GOTODIR}" -maxdepth 1 -type l -printf "%f\n")" -- "${COMP_WORDS[COMP_CWORD]}") )

} && complete -F _goto_complete goto

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    goto --help
fi
