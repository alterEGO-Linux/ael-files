## ----------------------------------------------------------------------- INFO
## [~/.xinitrc]
## author        : fantomH @alterEGO Linux
## created       : 2021-02-23 02:54:43 UTC
## updated       : 2024-01-01 04:30:01 UTC
## description   : Starts Window Manager with startx.

  ## Executed by startx (run your window manager from here)
  if [ -d /etc/X11/xinit/xinitrc.d ]; then
      for f in /etc/X11/xinit/xinitrc.d/*; do
          [ -x "$f" ] && . "$f"
      done
      unset f
  fi

  if [[ $(hostname) == "whatismyhostname" ]]; then
      xrandr --output DP1 --primary --auto --output VGA1 --left-of DP1
  fi

  case ${2} in

      qtile)
          exec /usr/bin/qtile start
          ;;
          
      *)
          exec /usr/bin/i3
          ;;

  esac

# vim: foldmethod=marker
## ------------------------------------------------------------- FIN ¯\_(ツ)_/¯
