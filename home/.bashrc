# ------------------------------------------------------------------------ INFO
# [/.bashrc]
# author        : Pascal Malouin (https://github.com/alterEGO-Linux)
# created       : 2021-02-26 02:54:43 UTC
# updated       : 2026-03-27 11:26:28 UTC
# description   : Bash configuration file.

# --- If not running interactively, don't do anything.
[[ $- != *i* ]] && return

LOADED='bashrc'

[ -f ${HOME}/.ael/.aelcore ] && . ${HOME}/.ael/.aelcore

# :----------/ BASH COMPLETION

  [ -r /usr/share/bash-completion/bash_completion ]                           \
  && . /usr/share/bash-completion/bash_completion
