<!------------------------------------------------------------------------ INFO
## [packages.md]
## author        : fantomH @alterEGO Linux
## created       : 2023-12-19 08:09:06 UTC
## updated       : 2023-12-26 14:27:41 UTC
## description   : Packages notes.
-->

## hydra

```
hydra: error while loading shared libraries: libsmbclient.so.0: cannot open shared object file: No such file or directory.
```

## nwg-displays

Monitor manager.

Requires package wlr-randr to run the GUI, but doesn't install it by default.

## wireshark

Separation of privilege has been implemented in Wireshark. It doesn't run as root anymore. The privileged user need to be added to the wireshark group.

## wlr-randr

Required by nwg-displays to run the GUI.

<!--
# vim: foldmethod=marker
## ------------------------------------------------------------- FIN ¯\_(ツ)_/¯ -->
