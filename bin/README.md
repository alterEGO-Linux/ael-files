<!--
=============================================================================== 
INFO
===============================================================================
[/bin/README.md]

Author      : Pascal Malouin (https://github.com/alterEGO-Linux)
Created     : 2026-08-30 15:46:01 UTC
Updated     : 2026-08-31 16:49:38 UTC
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

### deep-nmap

Runs a comprehensive Nmap scan against a target using service detection, OS detection, default NSE scripts, and traceroute.

```bash
deep-nmap 192.168.1.1
deep-nmap scanme.nmap.org --Pn
```

Additional Nmap options can be supplied directly. If `grc` is available, the scan output is automatically colorized.

**Requirements:** `nmap`, `sudo`, and the AEL Bash library.

### deep-scan

Performs a fast port discovery with RustScan followed by a detailed Nmap scan of the discovered ports.

```bash
deep-scan 192.168.1.1
deep-scan localhost
```

Nmap performs service and OS detection, runs its default scripts, and includes a traceroute. If `grc` is available, the Nmap output is automatically colorized.

**Requirements:** `rustscan`, `nmap`, `sudo`, and the AEL Bash library.

### delete

Safely deletes one or more directories with an interactive confirmation before each deletion.

```bash
delete old-directory
delete cache tmp backup
```

Directories that do not exist are skipped with an error message. The command refuses to proceed when no interactive terminal is available, preventing accidental unattended deletion.

### directory-size

Displays the size of the current directory and its largest immediate child directories.

```bash
directory-size
```

Results are sorted from largest to smallest and shown in human-readable units, making it easy to quickly identify directories consuming the most disk space.

### elevate

Repeats the previous shell command with elevated privileges using `sudo`.

```bash
pacman -Syu
# error: you cannot perform this operation unless you are root.

elevate
```

An optional interactive mode asks for confirmation before executing the command:

```bash
elevate --interactive
```

Because `elevate` relies on Bash command history, the script must be **sourced** rather than executed directly.

**Requirements:** `bash`, `sudo`, and the AEL Bash library.

### pacman-reset

Re-initializes the Arch Linux Pacman environment by rebuilding its synchronization data, refreshing the mirror list, and updating the Arch Linux keyring.

The script:

* Removes Pacman's local sync database.
* Uses `reflector` to generate a fresh Canadian HTTPS mirror list from recently synchronized mirrors, sorted by download rate.
* Forces a Pacman database refresh.
* Updates the `archlinux-keyring` package.

Useful for troubleshooting Pacman synchronization, outdated mirrors, or package-signing/keyring issues.

**Requirements:** `pacman`, `reflector`, `sudo`, `sed`, and the AlterEGO Linux Bash library (`~/.ael/lib/bash/ael`).

### show-utc

Displays the current date and time in UTC using a compact, standardized format.

```bash
show-utc
```

Example output:

```text
2026-08-31 12:29:19 UTC
```

### whoisweb

Queries WHOIS information over the web when the traditional WHOIS service on TCP port 43 is blocked or unavailable.

The command uses the whoisjs.com API to retrieve WHOIS data and formats the raw response for terminal output.

```bash
whoisweb example.com
```

Useful on restricted corporate, VPN, or public networks where direct WHOIS queries are not permitted.

**Requirements:** `curl`, `jq`, `sed`, and the AEL Bash library.

