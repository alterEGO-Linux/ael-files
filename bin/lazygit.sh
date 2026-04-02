# ------------------------------------------------------------------------ INFO
# [/home/ghost/.local/share/ael-files/bin/lazygit.sh]
# author        : Pascal Malouin @https://github.com/fantomH
# created       : 2026-04-02 00:31:34 UTC
# updated       : 2026-04-02 00:31:34 UTC
# description   : description

lazygit() {

    trap 'unset -f usage; trap - RETURN' RETURN
    
    usage() {
        cat <<EOF
================================================================================
[+] lazygit - Automated git pull, add, commit and pull..
================================================================================
Usage:
  lazygit [-h|--help] [-s|--status] <message...>

Options:
  -h, --help    Show this help.
  -s, --status  Show current git status and exits.

To do the full workflow:
  lazygit "This is the commit message." (if the script is sourced)
  bash lazygit.sh "This is the commit message." (if runned as regular script)


================================================================================
EOF
}

    local __show_status=0
    local __mgs=""
    local __blue=$'\033[34m'
    local __bold=$'\033[1m'
    local __red=$'\033[31m'
    local __reset=$'\033[0m'
    local __yellow=$'\033[33m'


    while [[ $# -gt 0 ]]; do
        case "$1" in
            -s|--status)
                __show_status=1
                shift
                ;;
            -h|--help)
                usage
                return 0
                ;;
            *)
                __mgs="${__mgs:+${__mgs} }$1"
                shift
                ;;
        esac
    done

    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        printf '%s\n' "${__red}[!]${__reset} Not inside a git repository." >&2
        return 1
    fi

    if ! git diff --quiet || ! git diff --cached --quiet; then
        git stash push -u -m "lazygit-auto-stash" >/dev/null 2>&1
        local __stashed=1
    fi

    printf '%s\n' "${__blue}[*]${__reset} Pulling..."
    git pull --rebase || {
        printf '%s\n' "${__red}[!]${__reset} Pull failed. Restoring stash..."
        git stash pop >/dev/null 2>&1
        return 1
    }

    if [[ "${__stashed:-0}" -eq 1 ]]; then
        git stash pop >/dev/null 2>&1
    fi

    printf '%s\n' "${__blue}[*]${__reset} Current status:"
    git status -s

    (( __show_status )) && return 0

    printf '%s\n' "${__blue}[*]${__reset} Staging all changes (git add -A)..."
    git add -A || return 1

    printf '%s\n' "${__blue}[*]${__reset} Staged changes:"
    git status -s

    if git diff --cached --quiet; then
        printf '%s\n' "${__blue}[*]${__reset} Nothing to commit."
        return 0
    fi

    if [[ -z "$__mgs" ]]; then
        printf '%s\n' "${__red}[!]${__reset} Commit message required." >&2
        return 1
    fi

    local __input
    read -p "${__blue}[?]${__reset} Proceed with commit and push? [y/N] " __input
        if [[ "${__input}" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            continue
        else
            printf '%s\n' "${__blue}[*]${__reset} Aborted. Unstaging changes..."
            git reset
            return 0
        fi

    git commit -m "$__mgs" || return 1

    printf '%s\n' "${__blue}[*]${__reset} Pushing..."
    git push
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    lazygit "$@"
fi
