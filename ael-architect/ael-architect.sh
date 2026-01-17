#!/usr/bin/env bash
# ------------------------------------------------------------------------ INFO
# [/ael-architect/ael-architect.sh]
# author        : Pascal Malouin @https://github.com/alterEGO-Linux
# created       : 2026-01-17 04:32:50 UTC
# updated       : 2026-01-17 04:32:50 UTC
# description   : Post Arch Linux install

set -euo pipefail

# --- ( default configuration )

__aelfiles_directory="${HOME}/.local/share/ael-files"
__ael_directory="${HOME}/.ael"

# --- scripts (/bin)
__aelfiles_bin_directory="${__aelfiles_directory}/bin"
__ael_bin_directory="${__ael_directory}/bin"
__ael_bin_applications=(
                        check-applications.sh
                        convert-toml-json.py
                        extractor.sh
                        tmuxplus.sh
                        tunnel-info.py
                       )
__ael_bin_symlinked=false
__ael_bin_updated_copy=true

# --- shellutils (/shellutils)

__aelfiles_shellutils_directory="${__aelfiles_directory}/shellutils"
__ael_shellutils_directory="${__ael_directory}/shellutils"
__shellutils=(

    # --- ( ansi-colors ) -> ANSI colors helper.
    ansi-colors

    # --- ( deep-nmap ) -> Deep Nmap scan.
    deep-nmap

    # --- ( deep-scan ) -> Scans IP with rustscan and nmap.
    deep-scan

    # --- ( delete ) -> Delete directories.
    delete

    # --- ( directory-size ) -> Check size of biggest directories.
    directory-size

    # --- ( docker-info ) -> Docker status helper.
    docker-info

    # --- ( elevate ) -> Repeats last command with sudo, if forgotten.
    elevate

    # --- ( extractor ) -> Compressed files universal extractor.
    extractor

    # --- ( getmp3 ) -> Extracting audio (.mp3) from video.
    getmp3

    # --- ( goto ) -> Simple directory bookmarks system.
    goto

    # --- ( ispeed ) -> Internet connection speed meter.
    ispeed

    # --- ( kali ) ->
    kali

    # --- ( pacman-reset ) -> Re-initialize pacman sync, mirrorlist and keyring.
    pacman-reset

    # --- ( ports ) -> Displays open ports.
    ports

    # --- ( processes ) -> Show processes.
    processes

    # --- ( ps-grep ) -> Show processes for a particular application.
    ps-grep

    # --- ( py-cleaner ) -> Clean python current directory.
    py-cleaner

    # --- ( py-server ) -> Create a Python HTTP server.
    py-server

    # --- ( reset-time ) -> Reset system time. Usefull when Windows boot screws time.
    reset-time

    # --- ( shell-info ) -> Show shell info.
    shell-info

    # --- ( show-utc ) -> Show UTC time.
    show-utc

    # --- ( snake-env ) -> Manage python -m venv.
    snake-env

    # --- ( termbin ) -> Netcat-based command-line pastebin.
    termbin

    # --- ( tmuxplus ) -> TMUX wrapper.
    tmuxplus

    # --- ( tunnel-info ) -> Display tunnel + VPN info.
    tunnel-info

    # --- ( whoisweb ) -> Query WHOIS web if <whois> port 43 is blocked on your network.
    whoisweb

    # --- ( utils/ael-fzf ) -> FZF wrapper.
    # ... Utility wrapper around FZF, commenting out might keep other shellutils
    # ... from working properly.
    utils/ael-fzf

    # --- ( utils/argument-parser ) -> Argument parser utility.
    # ... Commenting out might keep other shellutils from working properly.
    utils/argument-parser

    # --- ( utils/check-applications ) -> A more verbose command -v.
    utils/check-applications
                  )
__shellutils_symlinked=true
__shellutils_updated_copy=true
# --- ( end of configuration )

copy_files() {

    for __file in "${__files[@]}"; do

        src="${__src_directory}/${__file}"
        dst="${__dst_directory}/${__file}"

        [ -e "$src" ] || continue

        # --- symlink
        if [ "${__symlinked}" == true  ]; then
            # --- verify if symlink.
            if [ -L "$dst" ]; then
                # --- verify if dst points somewhere else, fix it.
                if [ "$(readlink -f -- "$dst")" != "$src" ]; then
                    ln -sfn "$src" "$dst"
                fi
            else
                # --- remove regular file if exist and create symlink.
                [ -e "$dst" ] && rm -rf -- "$dst"
                ln -s "$src" "$dst"
            fi
        else
            # --- remove symlink if exist.
            [ -L "$dst" ] && rm -f -- "$dst"

            if [ -f "$dst" ]; then
                # --- keep copy updated?
                if [ "${__updated}" == true ]; then
                    if [ "$(readlink -f -- "$dst")" != "$(readlink -f -- "$src")" ]; then
                        # --- copy only if content differs.
                        if ! cmp -s "$src" "$dst"; then
                            cp -f "$src" "$dst"
                        fi
                    fi
                fi
            else
                # --- make a copy.
                cp "$src" "$dst"
            fi
        fi

    done
}

set_bin() {

    __src_directory="${__aelfiles_bin_directory}"
    __dst_directory="${__ael_bin_directory}"
    __files=("${__ael_bin_applications[@]}")
    __symlinked="${__ael_bin_symlinked}"
    __updated="${__ael_bin_updated_copy}"

    mkdir -p "${__dst_directory}"
    copy_files

    for __file in "${__files[@]}"; do
        [[ -L "${__dst_directory}/${__file}" ]] || chmod +x "${__dst_directory}/${__file}"
    done

}

set_shellutils() {

    __src_directory="${__aelfiles_shellutils_directory}"
    __dst_directory="${__ael_shellutils_directory}"
    __files=("${__shellutils[@]}")
    __symlinked="${__shellutils_symlinked}"
    __updated="${__shellutils_updated_copy}"

    for directory in utils; do
        mkdir -p "${__dst_directory}/$directory"
    done

    copy_files
}

set_shellutils
set_bin
