<!-- INFO {{{

# [/ael/data/documentation/packages.md]
# author        : Pascal Malouin (https://github.com/alterEGO-Linux)
# created       : 2026-04-16 16:57:01 UTC
# updated       : 2026-04-16 16:57:01 UTC
# description   : Packages specification.
# tags          : 

}}} -->

# Packages

## docker compose

Docker compose is a plugin and requires a specific manual installation.

```shell
mkdir -p ~/.docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64   -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose
```

<!--
# vim: foldmethod=marker
-->
