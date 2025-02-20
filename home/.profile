# :----------------------------------------------------------------------- INFO
# :[~/.profile]
# :author        = alterEGO Linux
# :created       = 2021-04-28 14:59:01 UTC
# :updated       = 2025-02-20 11:54:31 UTC
# :description   = Loaded in non interactive shell.

# :----------/ MODULES

  [ -f ${HOME}/.ael/.aelcore ] && . ${HOME}/.ael/.aelcore

# :----------/ LOADED

  export LOADED='profile'
  # :Message function from bash-ael/messages.bash
  # message action "$(basename $BASH_SOURCE) @ $(date | sed 's/  / /g')."
