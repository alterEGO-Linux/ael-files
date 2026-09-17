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


### cheat

Provides an interactive terminal interface to [cheat.sh](https://cheat.sh) using `fzf`.

```bash
cheat
```

Browse and search available cheat sheets with a live preview, then open the selected reference in `less`. The preview automatically adapts to the terminal size.

**Requirements:** `curl`, `fzf`, `less`, `cat`, and the AEL Bash library.




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


### emojis

Provides an interactive emoji picker for the terminal using `fzf`.

```bash
emojis
```

Searches a built-in emoji database containing Unicode codes and descriptions. The selected emoji is automatically copied to the clipboard using `wl-copy` under Wayland or `xclip` under X11.

**Requirements:** `fzf`, `wl-copy` (Wayland) or `xclip` (X11), and the AEL Bash library.

### ports

Displays all listening and active TCP/UDP ports, including the processes associated with them.

```bash
ports
```

Uses `netstat` with elevated privileges to show addresses, ports, connection states, PIDs, and process names. If `grc` is available, the output is automatically colorized.

**Requirements:** `netstat`, `sudo`, and the AEL Bash library.

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


