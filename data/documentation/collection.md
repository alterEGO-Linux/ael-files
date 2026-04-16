<!-- INFO {{{

# [/ael/data/documentation/collection.md]
# author        : Pascal Malouin (https://github.com/alterEGO-Linux)
# created       : 2026-04-16 15:56:01 UTC
# updated       : 2026-04-16 15:56:01 UTC
# description   : Collection documentation.
# tags          : #reverse shell #wordlist

}}} -->

# Collection

## Reverse Shells

### PHP Web Shell

#### /collection/reverse-shells/webshell.php

ref. <https://github.com/ertaku12/one-liner-webshells>

This PHP webshell will, if the web server has PHP enable, display the stdout of the command.

For example, the following will return the username.

```url
http://127.0.0.1:8000/webshell.php?cmd=whoami
```

It must first be transferred to the server.

TEST (if you are using the alterEGO Linux system):
- Go to ~/.ael/collection/reverse-shells/.
- Start a php server:

```php
php -S 127.0.0.1:8000
```

- In your web browser, enter <http://127.0.0.1:8000/webshell.php?cmd=ls>.

You should see the directory listing.

This also works with TUI web browser.

```shell
lynx http://127.0.0.1:8000/webshell.php?cmd=ls
```

<!--
# vim: foldmethod=marker
-->
