#!/usr/bin/env bash
# :----------------------------------------------------------------------- INFO
# :[~/.local/bin/menu-ael-files.sh]
# :author        : alterEGO Linux
# :created       : 2025-02-21 14:44:41 UTC
# :updated       : 2025-02-21 14:44:45 UTC
# :description   : Opens AEL files in vim.

selection=$(rg --files --hidden --glob "!.git" ~/.local/share/ael-files/     \
    | fzf --color=gutter:-1                                                  \
          --margin=4%                                                        \
          --border=none                                                      \
          --prompt="Select a file ❯ "                                        \
          --header=" "                                                       \
          --no-hscroll                                                       \
          --reverse                                                          \
          -i                                                                 \
          --exact                                                            \
          --tiebreak=begin                                                   \
          --no-info                                                          \
          --pointer=•)

if [[ -n "$selection" ]]; then
    vim "$selection"
else
    echo "Nothing selected."
fi
