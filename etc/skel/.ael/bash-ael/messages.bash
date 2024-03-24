#! /usr/bin/env bash
# :----------------------------------------------------------------------- INFO
# :[~/.ael/bash-ael/messages.bash]
# :author        : fantomH @alteEGO Linux
# :created       : 2022-02-10 21:46:39 UTC
# :updated       : 2024-03-23 04:03:16 UTC
# :description   : Bash message module.

# :---------- [ MODULES ]

  [ -f ${HOME}/.ael/bash-ael/colors.bash ]                                    \
  && . ${HOME}/.ael/bash-ael/colors.bash

message() {

  # :Usage: message <type> <"Message">

  _msg="${2}"

  case ${1} in

    action )
      printf '%b\n' "${GREEN}[*]${RESET} ${BOLD}${_msg}${RESET}"
      ;;
    result )
      printf '%b\n' "${BLUE}[-]${RESET} ${_msg}"
      ;;
    question )
      ## The input will be in $_INPUT.
      read -p $'\033[34m[?]\033[0m \033[1m'"${_msg}"$'\033[0m ' _INPUT
      ;;
    alert )
      printf '%b\n' "${YELLOW}[!]${RESET} ${_msg}"
      ;;
    warning|error )
      printf '%b\n' "${RED}[!]${RESET} ${BOLD}${_msg}${RESET}"
      ;;
    title )
      printf '%b\n' "${BOLD}${_msg}${RESET}"
      ;;
  esac
}

# :------------------------------------------------------------- FIN ¯\_(ツ)_/¯
