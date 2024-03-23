# :----------------------------------------------------------------------- INFO
# :[~/.bashrc]
# :author        = alterEGO Linux
# :created       = 2021-02-26 02:54:43 UTC
# :updated       = 2024-03-23 00:10:07 UTC
# :description   = Bash config file.

  # :If not running interactively, don't do anything
  [[ $- != *i* ]] && return

# :---------- [ MODULES ]

  [ -f ${HOME}/.ael/.aelcore ] && . ${HOME}/.ael/.aelcore
  [ -f ~/.fzf.bash ] && source ~/.fzf.bash

# :---------- [ BASH COMPLETION ]

  [ -r /usr/share/bash-completion/bash_completion ]                           \
  && . /usr/share/bash-completion/bash_completion

# :---------- [ LOADED ]

  export LOADED='bashrc'
  # :Message function from bash-ael/messages.bash
  # message action "$(basename $BASH_SOURCE) @ $(date | sed 's/  / /g')."

# :------------------------------------------------------------- FIN ¯\_(ツ)_/¯
