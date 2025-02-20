#!/usr/bin/env bash
# :----------------------------------------------------------------------- INFO
# :[~/.local/bin/virtual-boxes.sh]
# :author        : alterEGO Linux
# :created       : 2025-02-18 20:57:09 UTC
# :updated       : 2025-02-18 20:57:14 UTC
# :description   : Launch Virtualbox VMs.

selection=$(vboxmanage list vms | awk -F\" '{print $2, $3}'                    \
    | fzf --color=gutter:-1                                                  \
          --margin=4%                                                        \
          --border=none                                                      \
          --prompt="START VM ❯ "                                             \
          --header=" "                                                       \
          --no-hscroll                                                       \
          --reverse                                                          \
          -i                                                                 \
          --exact                                                            \
          --tiebreak=begin                                                   \
          --no-info                                                          \
          --pointer=•)

# Extract the UUID (removes curly braces)
vm_uuid=$(echo "$selection" | awk '{gsub(/[{}]/, "", $2); print $2}')

# Start the selected VM
if [[ -n "$vm_uuid" ]]; then
    echo "Starting VM: $vm_uuid"
    vboxmanage startvm "$vm_uuid"
else
    echo "No VM selected."
fi
