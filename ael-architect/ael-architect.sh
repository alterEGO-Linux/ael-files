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
__aelfiles_bin="${__aelfiles_directory}/bin"
__ael_bin="${__ael_directory}/bin"
__ael_bin_applications=(
                        check-applications.sh
                        convert-toml-json.py
                        extractor.sh
                        tmuxplus.sh
                        tunnel-info.py
                       )
__ael_bin_symlinked=false
__ael_bin_updated_copy=true

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

    __src_directory="${__aelfiles_bin}"
    __dst_directory="${__ael_bin}"
    __files=("${__ael_bin_applications[@]}")
    __symlinked="${__ael_bin_symlinked}"
    __updated="${__ael_bin_updated_copy}"

    mkdir -p "${__dst_directory}"
    copy_files

    for __file in "${__files[@]}"; do
        [[ -L "${__dst_directory}/${__file}" ]] || chmod +x "${__dst_directory}/${__file}"
    done

}

set_bin
