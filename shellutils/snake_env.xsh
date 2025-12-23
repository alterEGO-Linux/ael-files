# :----------------------------------------------------------------------- INFO
# :[~/.ael/shellutils/snake_env.xsh]
# :author        : alterEGO Linux
# :description   : Manage python venvs in xonsh (no subshell; modifies current shell).

from __future__ import annotations

import os
import sys
import shlex
import subprocess
from pathlib import Path

__xonsh__.env.setdefault("SNAKE_ENV_DIR", str(Path.home() / ".ael/snake-env"))
__xonsh__.env.setdefault("SNAKE_ENV", None)
__xonsh__.env.setdefault("SNAKE_ENV_ACTIVE", None)

# --- Colors (xonsh supports ANSI directly) ---
BLUE  = "\033[34m"
GREEN = "\033[32m"
RED   = "\033[31m"
YELLOW= "\033[33m"
RESET = "\033[0m"

def _p(s: str) -> None:
    print(s)

def _err(s: str) -> None:
    print(s, file=sys.stderr)

def _q(s: str) -> str:
    return shlex.quote(s)

def _snake_env_dir() -> Path:
    # Keep compatibility with your existing env var
    base = os.environ.get("SNAKE_ENV_DIR") or str(Path.home() / ".ael/snake-env")
    return Path(base).expanduser()

def _env_path(name: str) -> Path:
    return _snake_env_dir() / name

def _bindir(venv: Path) -> Path:
    return venv / "bin"

def _python_in_venv(venv: Path) -> Path:
    return _bindir(venv) / "python"

def _ensure_base_dir() -> None:
    d = _snake_env_dir()
    d.mkdir(parents=True, exist_ok=True)
    $SNAKE_ENV_DIR = str(d)

def _is_active() -> bool:
    return str(__xonsh__.env.get("SNAKE_ENV_ACTIVE")) == "true"

def _set_prompt_hook() -> None:
    """
    Approximate your PROMPT_COMMAND logic:
    - adds session prefix
    - shows cwd
    - shows date
    - uses ❯ when on pts
    """
    from datetime import datetime

    def _snake_prompt():
        now = datetime.now().astimezone().strftime("%F %H:%M:%S %Z")
        cwd = str($PWD)
        name = str($SNAKE_ENV) if $SNAKE_ENV else ""
        # Detect pts-ish terminals; this is best-effort.
        try:
            tty = subprocess.check_output(["tty"], text=True).strip()
            arrow = "❯" if "pts" in tty else ">"
        except Exception:
            arrow = "❯"

        prefix = f"{GREEN}(snake-env: {name})-[{RESET}{cwd}{GREEN}] • [{now}]"
        return f"{RESET}{prefix}\n{GREEN}{arrow} {RESET}"

    # Xonsh prompt is a callable or string; callable is perfect for "dynamic date".
    $PROMPT = _snake_prompt

def _clear_prompt_hook() -> None:
    # If you want to restore a previous prompt, you can save it before setting.
    # For now: reset to xonsh default-ish prompt if available.
    try:
        del $PROMPT
    except Exception:
        pass

def _activate(name: str) -> int:
    if _is_active():
        _err(f"{RED}[!]{RESET} already in a session.")
        return 1

    _ensure_base_dir()
    venv = _env_path(name)
    py = _python_in_venv(venv)
    if not py.exists():
        _err(f"{RED}[!]{RESET} Environment {name} does not exists.")
        return 1

    _p(f"{BLUE}[-]{RESET} Starting python environment: {name}.")

    # "Outdated environment" check similar to your pyvenv.cfg grep:
    # Compare venv python realpath with current python realpath referenced in pyvenv.cfg (best-effort).
    cfg = venv / "pyvenv.cfg"
    if cfg.exists():
        try:
            cfg_text = cfg.read_text(errors="ignore")
            # If your system python path changed, pyvenv.cfg 'home = ...' may differ.
            # We'll just warn if "home =" doesn't match current interpreter directory.
            cur_py = Path(sys.executable).resolve()
            if "home" in cfg_text and str(cur_py.parent) not in cfg_text:
                _p(f"{RED}[!]{RESET} Outdated environment (possible). Run snake-env upgrade {name}.")
        except Exception:
            pass

    # Set snake vars
    $SNAKE_ENV = name
    $SNAKE_ENV_ACTIVE = "true"

    # Xonsh-native venv activation:
    # - set VIRTUAL_ENV
    # - prepend venv/bin to PATH (PATH is a list in xonsh)
    $VIRTUAL_ENV = str(venv.resolve())
    bind = str(_bindir(venv).resolve())
    if bind in $PATH:
        # move to front
        $PATH = [bind] + [p for p in $PATH if p != bind]
    else:
        $PATH.insert(0, bind)

    _set_prompt_hook()
    return 0

def _deactivate() -> int:
    if not _is_active():
        _err(f"{YELLOW}[!]{RESET} Not in a snake-env session.")
        return 1

    name = str($SNAKE_ENV) if $SNAKE_ENV else ""
    _p(f"{YELLOW}[!]{RESET} Quitting python environment: {name}.")

    # remove venv/bin from PATH
    if $VIRTUAL_ENV:
        bind = str(Path(str($VIRTUAL_ENV)) / "bin")
        $PATH = [p for p in $PATH if p != bind]

    $VIRTUAL_ENV = None
    $SNAKE_ENV = None
    $SNAKE_ENV_ACTIVE = None

    _clear_prompt_hook()
    return 0

def _create(name: str) -> int:
    _ensure_base_dir()
    venv = _env_path(name)
    if venv.exists():
        _err(f"{RED}[!]{RESET} Snake Environment {name} already exists.")
        return 1

    # Use system python to create the env
    subprocess.check_call([sys.executable, "-m", "venv", str(venv)])
    _p(f"{BLUE}[-]{RESET} Snake Environment {name} created.")
    return 0

def _cd() -> int:
    if not $SNAKE_ENV:
        _err(f"{RED}[!]{RESET} No active environment.")
        return 1
    d = _env_path(str($SNAKE_ENV))
    cd @(str(d))
    return 0

def _info() -> int:
    if not $SNAKE_ENV:
        _err(f"{RED}[!]{RESET} No active environment.")
        return 1

    name = str($SNAKE_ENV)
    path = _env_path(name)

    # --- Using xonsh `which`, instead of subprocess + `command -v python`,
    #     since it gives the system python path.
    py = $(which python).strip()

    # --- pip freeze.
    pkgs = []
    try:
        venv = __xonsh__.env.get("VIRTUAL_ENV")
        if not venv:
            raise RuntimeError("No active venv")

        py = str(Path(venv) / "bin" / "python")
        out = subprocess.check_output(
            [py, "-m", "pip", "freeze"],
            text=True,
            stderr=subprocess.DEVNULL,
        )
        pkgs = [l for l in out.splitlines() if l.strip()]
    except Exception:
        pkgs = []

    # pip freeze
    # pkgs = []
    # try:
        # out = subprocess.check_output(["pip", "freeze"], text=True, stderr=subprocess.DEVNULL)
        # pkgs = [l for l in out.splitlines() if l.strip()]
    # except Exception:
        # pkgs = []

    print(f'Info: snake-env "{name}"')
    print(f"    Env. Path     : {path}")
    print(f"    Python Path   : {py}")
    if pkgs:
        print(f"    Installed Pkg : {pkgs[0]}")
        for p in pkgs[1:]:
            print(f"                    {p}")
    else:
        print("    Installed Pkg : (none)")
    return 0

def _list() -> int:
    _ensure_base_dir()
    _p(f"{BLUE}[-]{RESET} Fetching python environments' list:")
    base = _snake_env_dir()
    envs = []
    for p in base.iterdir():
        if (p / "bin/python").exists():
            envs.append(p.name)
    if envs:
        for e in sorted(envs):
            print(e)
    else:
        print("(none found)")
    return 0

def _listall() -> int:
    _p(f"{BLUE}[-]{RESET} Fetching ALL python environments' list:")
    # Best-effort scan: find directories that look like venvs (bin/python + pyvenv.cfg)
    # (Can be slow; feel free to restrict to a few roots)
    roots = [Path.home()]
    found = []

    for root in roots:
        try:
            for py in root.rglob("bin/python"):
                venv = py.parent.parent
                if (venv / "pyvenv.cfg").exists():
                    found.append(str(venv))
        except Exception:
            pass

    if found:
        for p in sorted(set(found)):
            print(p)
    else:
        print("(none found)")
    return 0

def _upgrade(name: str | None) -> int:
    if name is None:
        if not $SNAKE_ENV:
            _err(f"{RED}[!]{RESET} Provide an env name or activate one first.")
            return 1
        name = str($SNAKE_ENV)

    venv = _env_path(name)
    if not venv.exists():
        _err(f"{RED}[!]{RESET} Environment {name} does not exist.")
        return 1

    subprocess.check_call([sys.executable, "-m", "venv", "--upgrade", str(venv)])
    _p(f"{BLUE}[-]{RESET} Upgraded environment: {name}")
    return 0

def _install_requirements(req_path: str) -> int:
    if not $SNAKE_ENV:
        _err(f"{RED}[!]{RESET} Activate an environment first.")
        return 1

    req = Path(req_path).expanduser()
    if not req.exists():
        _err(f"{RED}[!]{RESET} You must provide a valid requirements file.")
        return 1

    dest = _env_path(str($SNAKE_ENV)) / "requirements.txt"
    dest.write_text(req.read_text(errors="ignore"))
    subprocess.check_call(["pip", "install", "-r", str(dest)])
    return 0

def _install_jupyter() -> int:
    if not $SNAKE_ENV:
        _err(f"{RED}[!]{RESET} Activate an environment first.")
        return 1

    # Check jupyter
    try:
        subprocess.check_call(["jupyter-notebook", "--version"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        _err(f"{RED}[!]{RESET} Jupyter not installed!")
        return 1

    # Ensure ipykernel
    try:
        out = subprocess.check_output(["pip", "freeze"], text=True)
        has_ipykernel = any(l.lower().startswith("ipykernel==") for l in out.splitlines())
    except Exception:
        has_ipykernel = False

    if has_ipykernel:
        _p(f"{YELLOW}[-]{RESET} Module ipykernel for Jupyter already installed.")
    else:
        _p(f"{BLUE}[-]{RESET} Installing ipykernel for Jupyter.")
        subprocess.check_call(["pip", "install", "ipykernel"])

    name = str($SNAKE_ENV)
    subprocess.check_call([sys.executable, "-m", "ipykernel", "install", "--user", f"--name={name}"])

    # Create a default notebook in the env directory (same as your script)
    nb = _env_path(name) / f"{name}.ipynb"
    if not nb.exists():
        nb.write_text(r'''{
 "cells": [
  { "cell_type": "code", "execution_count": null, "metadata": {}, "outputs": [], "source": [] }
 ],
 "metadata": {
  "kernelspec": { "display_name": "Python 3 (ipykernel)", "language": "python", "name": "python3" },
  "language_info": {
   "codemirror_mode": { "name": "ipython", "version": 3 },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.x"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}''')
    return 0

def _notebook() -> int:
    if not $SNAKE_ENV:
        _err(f"{RED}[!]{RESET} Activate an environment first.")
        return 1
    name = str($SNAKE_ENV)
    nb = _env_path(name) / f"{name}.ipynb"
    if nb.exists():
        subprocess.Popen(["jupyter-notebook", str(nb)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return 0
    _err(f"{YELLOW}[!]{RESET} Notebook not found: {nb}")
    return 1

def _usage() -> None:
    print(rf"""================================================================================
[+] snake-env - Manage python venvs (xonsh).
================================================================================
Usage:
  snake-env create <environment-name>
  snake-env activate <environment-name>
  snake-env deactivate
  snake-env list
  snake-env listall
  snake-env cd
  snake-env info
  snake-env upgrade [environment-name]
  snake-env install-jupyter
  snake-env install-requirements <path/to/requirements.txt>
  snake-env notebook
  snake-env help

Notes:
  - This modifies the current xonsh session (no subshell).
  - PATH is a list in xonsh; activation prepends <venv>/bin.
================================================================================""")

def snake_env(args):
    """
    Entry-point for alias 'snake-env'.
    """
    if not args or args[0] in ("-h", "--help", "help"):
        _usage()
        return 0

    cmd = args[0]
    rest = args[1:]

    if cmd == "activate":
        if not rest:
            _err(f"{RED}[!]{RESET} Missing environment name.")
            return 1
        return _activate(rest[0])

    if cmd == "deactivate":
        return _deactivate()

    if cmd == "create":
        if not rest:
            _err(f"{RED}[!]{RESET} Missing environment name.")
            return 1
        return _create(rest[0])

    if cmd == "list":
        return _list()

    if cmd == "listall":
        return _listall()

    if cmd == "cd":
        return _cd()

    if cmd == "info":
        return _info()

    if cmd == "upgrade":
        name = rest[0] if rest else None
        return _upgrade(name)

    if cmd == "install-jupyter":
        return _install_jupyter()

    if cmd == "install-requirements":
        if not rest:
            _err(f"{RED}[!]{RESET} You must provide a valid requirements file.")
            return 1
        return _install_requirements(rest[0])

    if cmd == "notebook":
        return _notebook()

    _err(f"{RED}[!]{RESET} Unknown command: {cmd}")
    _usage()
    return 1

# Register alias
aliases["snake-env2"] = snake_env
