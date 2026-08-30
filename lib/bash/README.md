<!--
=============================================================================== 
INFO
===============================================================================
 [/lib/bash/README.md]

 Author      : Pascal Malouin (https://github.com/alterEGO-Linux)
 Created     : 2026-08-30 15:48:28 UTC
 Updated     : 2026-08-30 15:48:28 UTC
 Description : /lib/bash README.md
-------------------------------------------------------------------------------
-->

# /lib/bash/

### ael

Core AlterEGO Linux Bash import module.

Provides a simple `import` function inspired by Python imports, allowing AEL Bash scripts to load reusable modules from `~/.ael/lib/bash`.

Example:

```bash
source ~/.ael/lib/bash/ael
import messages applications
```

The requested modules are validated before being sourced, with an error returned if a module cannot be found.

### applications

Provides application dependency checking for AEL Bash scripts.

The `check_applications` function accepts one or more command names and verifies that they are available in the current environment.

Example:

```bash
check_applications pacman reflector sed
```

Returns an error and identifies the missing application if a required command is not installed.

### messages

Provides standardized CLI output for AEL Bash scripts.

The `message` function supports several message types with consistent formatting and terminal colors:

* `banner` — section headers
* `info` — general information
* `step` — operation in progress
* `success` — successful operation
* `error` — errors written to stderr

Example:

```bash
message step "Refreshing Pacman databases..."
message success "Pacman databases refreshed."
message error "Unable to update the keyring."
```

