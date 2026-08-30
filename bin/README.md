<!--
=============================================================================== 
INFO
===============================================================================
 [/bin/README.md]

 Author      : Pascal Malouin (https://github.com/alterEGO-Linux)
 Created     : 2026-08-30 15:46:01 UTC
 Updated     : 2026-08-30 16:15:49 UTC
 Description : /bin README.md
-------------------------------------------------------------------------------
-->

# /bin/

### busy

A small terminal novelty that makes the screen look impressively busy.

It continuously reads random data, displays it as a hexadecimal dump, and highlights occurrences of `ca fe` until stopped with `Ctrl+C`.

```bash
busy
```

Uses the AEL Bash library to verify the required commands (`bash`, `cat`, `grep`, and `hexdump`) before running.

### pacman-reset

Re-initializes the Arch Linux Pacman environment by rebuilding its synchronization data, refreshing the mirror list, and updating the Arch Linux keyring.

The script:

* Removes Pacman's local sync database.
* Uses `reflector` to generate a fresh Canadian HTTPS mirror list from recently synchronized mirrors, sorted by download rate.
* Forces a Pacman database refresh.
* Updates the `archlinux-keyring` package.

Useful for troubleshooting Pacman synchronization, outdated mirrors, or package-signing/keyring issues.

**Requirements:** `pacman`, `reflector`, `sudo`, `sed`, and the AlterEGO Linux Bash library (`~/.ael/lib/bash/ael`).

### whoisweb

Queries WHOIS information over the web when the traditional WHOIS service on TCP port 43 is blocked or unavailable.

The command uses the whoisjs.com API to retrieve WHOIS data and formats the raw response for terminal output.

```bash
whoisweb example.com
```

Useful on restricted corporate, VPN, or public networks where direct WHOIS queries are not permitted.

**Requirements:** `curl`, `jq`, `sed`, and the AEL Bash library.

