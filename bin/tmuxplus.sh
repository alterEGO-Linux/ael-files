#!/usr/bin/env sh
# ------------------------------------------------------------------------ INFO
# [/.ael/bin/tmuxplus.sh]
# author        : Pascal Malouin @https://github.com/alterEGO-Linux
# created       : 2020-10-15 17:14:53 UTC
# updated       : 2026-01-09 09:33:14 UTC
# description   : TMUX wrapper.


__red=$'\033[31m'
__reset=$'\033[0m'
__args=("${@}")

check_applications() {
    if [[ -e ${HOME}/.ael/bin/check-applications.sh ]]; then
        bash ${HOME}/.ael/bin/check-applications.sh "${@}"
    else
        for app in "${@}"; do
            if ! command -v $app >/dev/null 2>&1; then
                printf '%s\n' "${__red}[!]${__reset} ${app} is not installed."
                return 1
            fi
        done
    fi
}
check_applications tmux || exit 1

tmux_access_session() {

    # --- ref. <https://github.com/nwallace/dotfiles/blob/master/scripts/bin/functions>
    # ... Select and access TMUX sessions from FZF.

    check_applications fzf || exit 1

    __session="$(command tmux ls -F '#{session_name}' \
                  | fzf \
                  --color=gutter:-1 \
                  --margin=1% \
                  --border=rounded \
                  --prompt="SESSIONS" \
                  --header=" " \
                  --no-hscroll \
                  --reverse \
                  -i \
                  --exact \
                  --tiebreak=begin \
                  --no-info \
                  --pointer="•")"

    if [[ -n "${__session}" ]]; then
        # --- Check if in tmux session.
        if [[ -n $TMUX ]]; then
            env TERM=screen-256color tmux -u switch-client -t "${__session}"
        else
            env TERM=screen-256color tmux -u a -t "${__session}"
        fi
    else
        printf '%s\n' "${__red}[!]${__reset} Nothing selected."
    fi
}

tmux_background() {

    # --- send commands to a detached session.

    command tmux new-session -d -s ${__session}
    sleep 0.5
    command tmux send-keys -t ${__session} "${__cmd}" enter
}

tmux_wrapper() {

    # --- generate a temporary session to run a command and exit.

    __session=$(echo TEMP${RANDOM})

    env TERM=screen-256color tmux -u new-session -d -s "${__session}"
    command tmux send-keys -t "${__session}" "${__cmd} && exit 0" enter
}

tmux_usage() {
    cat <<EOF
================================================================================
[+] tmuxplus - TMUX wrapper.
================================================================================
Usage: tmuxplus [OPTIONS] <session>

A wrapper around TMUX.

Options:
  -a, --access                     Uses fzf to attach or switch to a session.
  -b, --background                 Run a command in a detached session.
  -h, --help                       Display this help message.
  -w, --wrapper                    Generate a temporary session to run a command and exit.
                                   Useful to launch a GUI from the terminal.

Examples:
  tmuxplus -b LOOP "while true; do echo WHAT; done"
                                   # Create a session called LOOP and echo WHAT
                                     until terminated manually.
  tmuxplus -w libreoffice          # Launches libreoffice and exit the tmux
                                     session when quitting libreoffice.
================================================================================
EOF
}

# --- show help if no arguments.
if [[ "${#}" -eq 0 ]]; then
    tmux_usage
    exit 0
fi

# --- show help and ignore other arguments.
for __arg in "${__args[@]}"; do
    if [[ "${__arg}" == "-h" || "${__arg}" == "--help" ]]; then
        tmux_usage
        exit 0
    fi
done

case ${1} in
    -a|--access )
        tmux_access_session
        ;;

    -b|--background )
        shift
        __session="${1}"
        __cmd="${2}"
        tmux_background
        ;;

    -w|--wrapper )
        shift
        __cmd="${1}"
        tmux_wrapper
        ;;

    * )
        tmux_usage
        ;;
esac
