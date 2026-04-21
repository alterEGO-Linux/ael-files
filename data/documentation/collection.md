<!-- INFO {{{

# [/ael/data/documentation/collection.md]
# author        : Pascal Malouin (https://github.com/alterEGO-Linux)
# created       : 2026-04-16 15:56:01 UTC
# updated       : 2026-04-20 17:43:05 UTC
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

## Wordlists

### best1050.txt

Curated list of 1049 words designed for fast and standard web directory/file brute-forcing.

The origin of best1050.txt is not clear, but was an early addition to DIRB CLI-based brute forcing tool. Thus, when DIRB is installed, the list can be found at `/usr/share/dirb/wordlists/others/best1050.txt`.

It used to be available on SecLists GitHub, but was removed.

Version used by alterEGO Linux is from DIRB.

### big.txt

Curated medium size (according to modern standard) directories and files common names.

This list is part of the DIRB wordlist's buddle.

Version used by alterEGO Linux is from DIRB ('/usr/share/dirb/wordlists/big.txt').

### directory-list-2.3-medium.txt

Part of the OWASP DirBuster Project, lead by James Fisher aimed at web directory/file discovery.

Version used by alterEGO Linux is from Dirbuster ('/usr/share/dirbuster/directory-list-2.3-medium.txt').

### raft-large-files.txt

Part of the RAFT (Response Analysis and Further Testing Tool) project <https://code.google.com/archive/p/raft/>.

Version used by alterEGO Linux is from SecLists.

```shell
curl https://raw.githubusercontent.com/danielmiessler/SecLists/refs/heads/master/Discovery/Web-Content/raft-large-words.txt -o $AEL_FILES/collection/wordlists/raft-large-files.txt
```

### Rockyou.txt

The rockyou.txt file is one of the most well-known password datasets in cybersecurity history. It originates from a 2009 data breach of the company RockYou, where millions of user passwords were exposed due to poor security practices—specifically, storing passwords in plain text. Containing over 14 million real-world passwords, rockyou.txt has since become a widely used resource for security research, password strength analysis, and penetration testing. Its significance lies in revealing common human tendencies in password creation, highlighting patterns such as simple words, names, and predictable number combinations, which continue to inform modern approaches to authentication and cybersecurity defense.

Version sourced from Kali Linux.

```shell
curl https://gitlab.com/kalilinux/packages/wordlists/-/raw/kali/master/rockyou.txt.gz -o $AEL_FILES/collection/wordlists/rockyou.txt.gz
```

### xplatform.txt

SQL injection list.

Version used by alterEGO Linux is from Fuzzdb-project.

```shell
curl https://raw.githubusercontent.com/fuzzdb-project/fuzzdb/refs/heads/master/attack/sql-injection/detect/xplatform.txt -o $AEL_FILES/collection/wordlists/raft-large-files.txt
```

<!--
# vim: foldmethod=marker
-->
