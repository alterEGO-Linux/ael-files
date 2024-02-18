## ----------------------------------------------------------------------- INFO
## [~/.bashrc]
## author        = alterEGO Linux
## created       = 2021-02-26 02:54:43 UTC
## updated       = 2024-02-17 12:55:11 UTC
## description   = Bash config file.

  ##: If not running interactively, don't do anything
  [[ $- != *i* ]] && return

## -------------------- [ MODULES ]

  [ -f ${HOME}/.ael/.aelcore ] && . ${HOME}/.ael/.aelcore
  [ -f ~/.fzf.bash ] && source ~/.fzf.bash

## ---------- [ BASH COMPLETION ]

  [ -r /usr/share/bash-completion/bash_completion ]                           \
  && . /usr/share/bash-completion/bash_completion

## ---------- [ LOADED ]

  export LOADED='bashrc'
  ## Message function from bash-ael/messages.bash
  # message action "$(basename $BASH_SOURCE) @ $(date | sed 's/  / /g')."

# vim: syntax=sh
# vim: foldmethod=marker
## ------------------------------------------------------------- FIN ¯\_(ツ)_/¯
