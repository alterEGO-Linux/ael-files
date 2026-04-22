<!-- INFO {{{

# [/ael/data/documentation/packages.md]
# author        : Pascal Malouin (https://github.com/alterEGO-Linux)
# created       : 2026-04-16 16:57:01 UTC
# updated       : 2026-04-16 16:57:01 UTC
# description   : Packages specification.
# tags          : 

}}} -->

# Packages

This explains different application installation and set up.

## docker compose

Docker compose is a plugin and requires a specific manual installation.

```shell
mkdir -p ~/.docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64   -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose
```

## linPEAS

LinPEAS is a script that search for possible paths to escalate privileges on Linux/Unix*/MacOS hosts. The checks are explained on book.hacktricks.wiki.

```shell
curl -L https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh -o $AEL_BIN/linpeas.sh
```

Read <https://github.com/peass-ng/PEASS-ng/blob/master/linPEAS/README.md> for usage.

<!--
# vim: foldmethod=marker
-->
