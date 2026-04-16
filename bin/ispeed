#!/usr/bin/env bash
# ------------------------------------------------------------------------ INFO
# [/.ael/bin/ispeed]
# author        : Pascal Malouin (https://github.com/alterEGO-Linux)
# created       : 2024-05-16 14:54:18 UTC
# updated       : 2026-04-09 01:45:37 UTC
# description   : Internet connection speed meter.

ispeed() {

    local ARGUMENTS_INPUT=("${@}")
    local __selection
    local __blue=$'\033[34m'
    local __red=$'\033[31m'
    local __reset=$'\033[0m'

    trap 'unset -f run_method usage use_fzf; trap - RETURN' RETURN

    check_applications() {
      local __app
      for __app in "${@}"; do
          if ! command -v $__app >/dev/null 2>&1; then
                printf '%s\n' "${__red}[!]${__reset} ${__app} is not installed."
                return 1
            fi
        done
    }

    usage() {
      cat <<EOF
================================================================================
[+] ispeed - Calculate Internet connection speed.
================================================================================
Usage:
  ispeed [--fzf|--web METHOD|--cli METHOD|--git METHOD|--help]

ispeed offers different ways to calculate your Internet speed.

Oprions:
  --fzf    Uses fzf to display and select a method.
  --cli    Uses a local application. Requires a METHOD.
  --git    Uses git, curl, wget etc. to run command.
           Requires a METHOD.
  --web    Uses default browser. Requires a METHOD.

Methods:
  - (cli)  speedtest
           Uses the speedtest-cli package.
  - (git)  speedtest
           Uses curl and python.
           URL: https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py
  - (web)  speedtest
           URL: https://www.speedtest.net/
  - (web)  Fast.com
           URL: https://fast.com
  - (web)  speedof.me
           URL: https://speedof.me/

================================================================================
EOF
    }

    use_fzf() {

        __selection=$(printf "%s\n" "${__methods[@]}" \
              | fzf \
              --color=gutter:-1 \
              --margin=1% \
              --border=rounded \
              --prompt="SELECT ❯ " \
              --header=" " \
              --no-hscroll \
              --reverse \
              -i \
              --exact \
              --tiebreak=begin \
              --no-info \
              --pointer="•")
    }

    run_method() {
        if [[ -n "${__selection}" ]]; then
            printf '%s\n' "${__blue}[+]${__reset} ispeed - Using ${__selection}"
            printf '%s\n' ''
            if [[ "${__selection}" == "(cli) speedtest" ]]; then
                check_applications speedtest || return 1
                command speedtest --secure
            elif [[ "${__selection}" == "(git) speedtest" ]]; then
                check_applications curl python || return 1
                    command curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py \
                    | command python - --secure
            elif [[ "${__selection}" == "(web) speedtest" ]]; then
                ${__browser} "https://www.speedtest.net/"
            elif [[ "${__selection}" == "(web) Fast.com" ]]; then
                ${__browser} "https://fast.com"
            elif [[ "${__selection}" == "(web) speedof.me" ]]; then
                ${__browser} "https://speedof.me/"
            fi
        else
            printf '%s\n' "${__red}[!]${__reset} ispeed - Aborting..."
        fi
    }

    local __methods
    __methods=("(cli) speedtest"
             "(git) speedtest"
             "(web) speedtest"
             "(web) Fast.com"
             "(web) speedof.me")

    local __browser="${BROWSER:-xdg-open}"

    # --| No arguments.
    if [[ $# == 0 ]]; then
        check_applications fzf || return 1
        use_fzf
        run_method
        return 0
    fi

    # --| show help and ignore other arguments.
    local i
    for i in "${ARGUMENTS_INPUT[@]}"; do
        if [[ "${i}" == "-h" || "${i}" == "--help" ]]; then
            usage
            return 0
        fi
    done

    # --| arguments parser.
    for i in "${!ARGUMENTS_INPUT[@]}"; do
        if [[ "${ARGUMENTS_INPUT[i]}" == "--fzf" ]]; then
            check_applications fzf || return 1
            use_fzf
            run_method
            return 0
        elif [[ "${ARGUMENTS_INPUT[i]}" == "--cli" ]]; then
            if [[ -n "${ARGUMENTS_INPUT[i+1]}" && "${ARGUMENTS_INPUT[i+1]}" == "speedtest" ]]; then
                __selection="(cli) speedtest"
                run_method
                return 0
            else
                usage
                printf '%s\n' ""
                printf '%s\n' "${__red}[!]${__reset} --cli requires a valid argument."
                return 1
            fi
        elif [[ "${ARGUMENTS_INPUT[i]}" == "--git" ]]; then
            if [[ -n "${ARGUMENTS_INPUT[i+1]}" && "${ARGUMENTS_INPUT[i+1]}" == "speedtest" ]]; then
                __selection="(git) speedtest"
                run_method
                return 0
            else
                usage
                printf '%s\n' ""
                printf '%s\n' "${__red}[!]${__reset} --git requires a valid argument."
                return 1
            fi

        elif [[ "${ARGUMENTS_INPUT[i]}" == "--web" ]]; then
            if [[ -n "${ARGUMENTS_INPUT[i+1]}" ]]; then
                if [[ "${ARGUMENTS_INPUT[i+1]}" == "speedtest" ]]; then
                    __selection="(web) speedtest"
                    run_method
                    return 0
                elif [[ "${ARGUMENTS_INPUT[i+1]}" == "Fast.com" ]]; then
                    __appselection="(web) Fast.com"
                    run_method
                    return 0
                elif [[ "${ARGUMENTS_INPUT[i+1]}" == "speedof.me" ]]; then
                    __selection="(web) speedof.me"
                    run_method
                    return 0
                else
                    usage
                    printf '%s\n' ""
                    printf '%s\n' "${__red}[!]${__reset} --web requires a valid argument."
                    return 1
                fi
            else
                usage
                printf '%s\n' ""
                printf '%s\n' "${__red}[!]${__reset} --web requires a valid argument."
                return 1
            fi
        fi
    done

    # --| garbage argument collector.
    usage
    printf '%s\n' ""
    printf '%s\n' "${__red}[!]${__reset} No valid arguments found."
    return 1
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    ispeed "$@"
fi
