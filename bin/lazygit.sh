#! /usr/bin/env bash
# ------------------------------------------------------------------------ INFO
# [/.ael/bin/lazygit.sh]
# author        : Pascal Malouin (https://github.com/alterEGO-Linux)
# created       : 2026-04-02 00:31:34 UTC
# updated       : 2026-04-02 15:02:25 UTC
# description   : Automated git pull, add, commit and push.

lazygit() {

    trap 'unset -f usage; trap - RETURN' RETURN
    
    usage() {
        cat <<EOF
================================================================================
[+] lazygit - Automated git pull, add, commit and push.
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

    # --- Makes sure you're inside a git repo.
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        printf '%s\n' "${__red}[!]${__reset} Not inside a git repository." >&2
        return 1
    fi

    # --- Stach non commited and pull.
    local __stashed=0

    if ! git diff --quiet || ! git diff --cached --quiet || [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
        git stash push -u -m "lazygit-auto-stash" >/dev/null 2>&1 || {
            printf '%s\n' "${__red}[!]${__reset} Failed to create temporary stash." >&2
            return 1
        }
        __stashed=1
    fi

    printf '%s\n' "${__blue}[*]${__reset} Pulling..."
    if ! git pull --rebase; then
        printf '%s\n' "${__red}[!]${__reset} Pull failed."

        if (( __stashed )); then
            printf '%s\n' "${__yellow}[*]${__reset} Restoring stashed changes..."
            if ! git stash pop >/dev/null 2>&1; then
                printf '%s\n' "${__red}[!]${__reset} Failed to restore stash cleanly. Please check 'git stash list'." >&2
            fi
        fi

        return 1
    fi

    if (( __stashed )); then
        printf '%s\n' "${__blue}[*]${__reset} Restoring stashed changes..."
        if ! git stash pop >/dev/null 2>&1; then
            printf '%s\n' "${__red}[!]${__reset} Failed to restore stash cleanly. Please check 'git stash list'." >&2
            return 1
        fi
    fi

    # --- Shows status.
    printf '%s\n' "${__blue}[*]${__reset} Current status:"
    git status -s

    # --- If --status option, exits now.
    (( __show_status )) && return 0

    # --- Staging all.
    printf '%s\n' "${__blue}[*]${__reset} Staging all changes (git add -A)..."
    git add -A || return 1

    # --- Show status after staging;
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

    # --- Confirmation request for commit and push.
    local __input
    printf "${__blue}[?]${__reset} Proceed with commit and push? [y/N] "
    read -r __input

    if [[ "${__input}" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        :
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
