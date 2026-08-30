<!-- INFO {{{

# [/ael/dev/notes.md]
# author        : Pascal Malouin (https://github.com/alterEGO-Linux)
# created       : 2026-05-08 19:18:51 UTC
# updated       : 2026-05-08 19:18:51 UTC
# description   : For dev only.

}}} -->

## Pipewire

```
systemctl --user enable --now pipewire pipewire-pulse wireplumber
```

## Qt style

For pcmanfm-qt

```
sudo pacman -S qt6ct kvantum
```

Add to hyprland.conf

```
# --- ( Qt ) ------------------------------------------------------------------

env = QT_QPA_PLATFORMTHEME,qt6ct
```

Run

```
qt6ct
```

Under the tab Appearance / Style, choose kvantum-dark and Color scheme "Style's colors".

<!--
# vim: foldmethod=marker
-->

## GTK4 and pavucontrol

~/.config/gtk-4.0/settings.ini

```ini
[Settings]
gtk-theme-name=Windows-10-Dark-master
gtk-icon-theme-name=Windows-10-master
gtk-font-name=Cantarell 11
gtk-cursor-theme-name=default
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=1
```

gtk-application-prefer-dark-theme must be set to 1 for dark theme.
