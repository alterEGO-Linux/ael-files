#!/usr/bin/env python3
# ------------------------------------------------------------------------ INFO
# [bin/docker-info.py]
# author        : Pascal Malouin @https://github.com/alterEGO-Linux
# created       : 2025-09-04 10:15:46 UTC
# updated       : 2025-12-22 02:27:23 UTC
# description   : Docker status helper.

"""
Docker status helper with Rich tables.

Args:
  --containers   Show containers table (ID, Name, Status, Image, Networks, IP)
  --images       Show images table (Image ID, Repository, Tag, Created, Size)
  --all          Show both containers and images

Behavior:
  - On Linux with systemd: if docker.service is not "active", restart it via:
        systemctl restart docker
  - Uses docker CLI (no external Docker SDK)

Requires:
  - docker CLI in PATH
  - rich (pip install rich)
"""

from __future__ import annotations
import argparse
import platform
import shutil
import subprocess
import sys

try:
    from rich.console import Console
    from rich.table import Table
    from rich.panel import Panel
    from rich import box
except ImportError:
    print("[!] This script requires the 'rich' package. Install it with: pip install rich", file=sys.stderr)
    sys.exit(1)

console = Console()

# --- ( UTILITIES )

def run(cmd: list[str], check: bool = False) -> subprocess.CompletedProcess:
    """Run a command and return the completed process (stdout captured as text)."""
    return subprocess.run(cmd, check=check, text=True, capture_output=True)

def command_exists(cmd: str) -> bool:
    return shutil.which(cmd) is not None

def start_docker_service() -> None:
    """
    If systemd reports docker.service is not active, restart it with systemctl.
    Silently skip on non-Linux or if systemctl is unavailable.
    """
    if platform.system() != "Linux" or not command_exists("systemctl"):
        return

    try:
        res = run(["systemctl", "is-active", "docker.service"])
        state = res.stdout.strip()
    except Exception as e:
        console.print(f"[yellow][!][/yellow] Could not query systemd state: {e}")
        return

    if state != "active":
        console.print("[blue][*][/blue] Docker service is not active. Restarting via systemd...")
        try:
            run(["systemctl", "restart", "docker"], check=True)
            verify = run(["systemctl", "is-active", "docker.service"])
            if verify.stdout.strip() != "active":
                console.print("[yellow][!][/yellow] docker.service did not become active after restart.")
        except subprocess.CalledProcessError as e:
            msg = e.stderr.strip() or str(e)
            console.print(f"[red][!][/red] Failed to restart docker.service: {msg}")

# --- ( CONTAINERS )

def list_containers() -> int:
    """
    Render a Rich table of containers:
      CONTAINER ID | NAME | STATUS | IMAGE | NETWORKS | IP ADDR
    Returns non-zero on errors.
    """
    if not command_exists("docker"):
        console.print("[red][!][/red] Docker CLI not found in PATH.")
        return 1

    try:
        ps = run(
            ["docker", "ps", "-a", "--format", "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}"],
            check=True,
        )
    except subprocess.CalledProcessError as e:
        console.print(Panel.fit(f"`docker ps -a` failed:\n{e.stderr.strip() or e}", title="Error", border_style="red"))
        return 2

    lines = [ln for ln in ps.stdout.splitlines() if ln.strip()]
    if not lines:
        console.print("[yellow][!][/yellow] No containers found.")
        return 0

    table = Table(
        title="[*] Docker Containers",
        box=box.SIMPLE,
        show_lines=False,
        title_style="bold blue",
        title_justify="left",
    )
    table.add_column("CONTAINER ID")
    table.add_column("NAME")
    table.add_column("STATUS")
    table.add_column("IMAGE")
    table.add_column("NETWORKS")
    table.add_column("IP ADDR")

    exit_code = 0
    for line in lines:
        try:
            container_id, name, image, status = line.split("\t", 3)
        except ValueError:
            continue

        # --- network names
        try:
            networks_cp = run(
                [
                    "docker", "inspect",
                    "-f", "{{range $k, $v := .NetworkSettings.Networks}}{{printf \"%s,\" $k}}{{end}}",
                    container_id,
                ],
                check=True,
            )
            networks = networks_cp.stdout.strip().rstrip(",") or "-"
        except subprocess.CalledProcessError:
            networks = "-"
            exit_code = exit_code or 3

        # --- IP addresses
        try:
            ip_cp = run(
                [
                    "docker", "inspect",
                    "-f", "{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}",
                    container_id,
                ],
                check=True,
            )
            ip_addr = ip_cp.stdout.strip() or "-"
        except subprocess.CalledProcessError:
            ip_addr = "-"
            exit_code = exit_code or 3

        table.add_row(container_id, name, status, image, networks, ip_addr)

    console.print(table)
    return exit_code

# --- ( IMAGES )

def list_images() -> int:
    """
    Render a Rich table similar to `docker images` with:
      IMAGE ID | REPOSITORY | TAG | CREATED | SIZE
    """
    if not command_exists("docker"):
        console.print("[red][!][/red] Docker CLI not found in PATH.")
        return 1

    try:
        imgs = run(
            ["docker", "images", "--format", "{{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.CreatedSince}}\t{{.Size}}"],
            check=True,
        )
    except subprocess.CalledProcessError as e:
        console.print(Panel.fit(f"`docker images` failed:\n{e.stderr.strip() or e}", title="Error", border_style="red"))
        return 2

    lines = [ln for ln in imgs.stdout.splitlines() if ln.strip()]
    if not lines:
        console.print("[yellow][!][/yellow] No images found.")
        return 0

    table = Table(
        title="[*] Docker Images",
        box=box.SIMPLE,
        show_lines=False,
        title_style="bold blue",
        title_justify="left",
    )
    table.add_column("IMAGE ID")
    table.add_column("REPOSITORY")
    table.add_column("TAG")
    table.add_column("CREATED")
    table.add_column("SIZE")

    for line in lines:
        try:
            img_id, repo, tag, created, size = line.split("\t", 4)
        except ValueError:
            continue
        table.add_row(img_id, repo, tag, created, size)

    console.print(table)
    return 0

# --- ( CLI )

def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Docker status helper with Rich tables")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--containers", action="store_true", help="Show containers table.")
    group.add_argument("--images", action="store_true", help="Show images table.")
    group.add_argument("--all", action="store_true", help="Show both containers and images.")

    args = parser.parse_args(argv)

    start_docker_service()

    exit_code = 0
    if args.containers or args.all:
        exit_code = list_containers() or exit_code

    if args.images or args.all:
        exit_code = list_images() or exit_code

    return exit_code

if __name__ == "__main__":
    sys.exit(main())
