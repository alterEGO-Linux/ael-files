#!/usr/bin/env sh
# ------------------------------------------------------------------------ INFO
# [/.ael/bin/busy]
# author        : Pascal Malouin @https://github.com/alterEGO-Linux
# created       : 2023-08-01 19:55:12 UTC
# updated       : 2026-01-22 06:21:00 UTC
# description   : Look busy when the boss comes around.

# --- (ref) <https://www.commandlinefu.com/commands/view/6663/pretend-to-be-busy-in-office-to-enjoy-a-cup-of-coffee>
# --- CTRL+c to quit.

command cat /dev/urandom \
| command hexdump -C \
| command grep --color=always 'ca fe'
