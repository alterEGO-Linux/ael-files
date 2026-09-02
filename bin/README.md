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

### arch-pkg

Provides convenient command-line helpers for managing Arch Linux package state with `paru`.

```bash
arch-pkg required-by <package>
arch-pkg mark-as-explicit <package>
arch-pkg list-explicit
arch-pkg list-orphans
```

Can inspect package dependencies, mark packages as explicitly installed, and list explicit or orphaned packages.

**Requirements:** Python, `click`, and `paru`.

### busy

A small terminal novelty that makes the screen look impressively busy.

It continuously reads random data, displays it as a hexadecimal dump, and highlights occurrences of `ca fe` until stopped with `Ctrl+C`.

```bash
busy
```

Uses the AEL Bash library to verify the required commands (`bash`, `cat`, `grep`, and `hexdump`) before running.

### cheat

Provides an interactive terminal interface to [cheat.sh](https://cheat.sh) using `fzf`.

```bash
cheat
```

Browse and search available cheat sheets with a live preview, then open the selected reference in `less`. The preview automatically adapts to the terminal size.

**Requirements:** `curl`, `fzf`, `less`, `cat`, and the AEL Bash library.

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

### dicom-tag

Provides an interactive DICOM tag reference using `fzf`.

```bash
dicom-tag
```

Searches a built-in database of DICOM tags by tag number or attribute name, making it easy to quickly look up identifiers such as `PatientID`, `StudyInstanceUID`, or `Modality`.

**Requirements:** `fzf`, `sort`, and the AEL Bash library.

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

### emojis

Provides an interactive emoji picker for the terminal using `fzf`.

```bash
emojis
```

Searches a built-in emoji database containing Unicode codes and descriptions. The selected emoji is automatically copied to the clipboard using `wl-copy` under Wayland or `xclip` under X11.

**Requirements:** `fzf`, `wl-copy` (Wayland) or `xclip` (X11), and the AEL Bash library.

### pacman-reset

Re-initializes the Arch Linux Pacman environment by rebuilding its synchronization data, refreshing the mirror list, and updating the Arch Linux keyring.

The script:

* Removes Pacman's local sync database.
* Uses `reflector` to generate a fresh Canadian HTTPS mirror list from recently synchronized mirrors, sorted by download rate.
* Forces a Pacman database refresh.
* Updates the `archlinux-keyring` package.

Useful for troubleshooting Pacman synchronization, outdated mirrors, or package-signing/keyring issues.

**Requirements:** `pacman`, `reflector`, `sudo`, `sed`, and the AlterEGO Linux Bash library (`~/.ael/lib/bash/ael`).

### ports

Displays all listening and active TCP/UDP ports, including the processes associated with them.

```bash
ports
```

Uses `netstat` with elevated privileges to show addresses, ports, connection states, PIDs, and process names. If `grc` is available, the output is automatically colorized.

**Requirements:** `netstat`, `sudo`, and the AEL Bash library.

### processes

Displays a detailed list of all currently running processes.

```bash
processes
```

Shows process ownership, CPU and memory usage, state, start time, and command information using `ps aux`. If `grc` is available, the output is automatically colorized.

**Requirements:** `ps` and the AEL Bash library.

### py-cleaner

Cleans Python-generated cache files from the current directory and its subdirectories.

```bash
py-cleaner
```

Recursively removes `__pycache__` directories and compiled `.pyc` and `.pyo` files, providing a quick way to clean a Python project tree.

**Requirements:** `find` and the AEL Bash library.

### shell-info

Inspects the current Bash environment and displays detailed information about aliases, functions, variables, builtins, and shell keywords.

```bash
shell-info tmuxplus
shell-info --fzf
shell-info --sourced
shell-info --sourced-tree
```

When available, `shell-info` identifies where aliases, functions, and variables were defined. It can also interactively browse the shell environment with `fzf`, list files loaded during shell startup, or display them as a dependency tree.

The script must be **sourced** to inspect the current shell environment correctly.

**Requirements:** `bash`, `fzf`, `awk`, `grep`, `sed`, `tac`, and the AEL Bash library.


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

