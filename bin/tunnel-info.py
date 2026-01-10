#!/usr/bin/env python3
# ------------------------------------------------------------------------ INFO
# [/.ael/bin/tunnel-info.py]
# author        : Pascal Malouin @https://github.com/alterEGO-Linux
# created       : 2025-09-05 20:36:58 UTC
# updated       : 2026-01-10 12:19:44 UTC
# description   : Display Tunnels/VPN info.

import os, re, glob, subprocess
from collections import defaultdict

from rich.console import Console
from rich.table import Table
from rich import box

# ---------- [ utilities ]

def run(cmd):
    p = subprocess.run(cmd, capture_output=True, text=True)
    return p.returncode, p.stdout, p.stderr

def sh_quote(s: str) -> str:
    return "'" + s.replace("'", "'\\''") + "'"

def is_tunnel_iface(iface: str) -> bool:
    # --- via link flags -> link/none or POINTOPOINT often indicates a tunnel.
    rc, out, _ = run(["ip", "-o", "link", "show", "dev", iface])
    if rc != 0 or not out:
        return False
    line = out.strip()
    if "link/none" in line:
        return True
    m = re.search(r"<([^>]*)>", line)
    if m and "POINTOPOINT" in {f.strip().upper() for f in m.group(1).split(",")}:
        return True
    return False

#  ---------- [ tunnels/vpn ]

IFACE_TUN_RE = re.compile(
    r"^(?:tun\w*|tap\w*|wg\d*|tailscale\d*|zt[0-9a-f]+|ppp\w*|vpn\w*|utun\d*|nordtun)$",
    re.IGNORECASE,
)

IPV4_RE = re.compile(r"\binet\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\/\d+")

def list_vpn_ifaces():
    """Return list of (iface, ipv4) considered tunnels/VPNs (global scope)."""
    rc, out, _ = run(["ip", "-o", "addr", "show", "scope", "global"])
    if rc != 0:
        return []
    found = []
    seen = set()
    for line in out.splitlines():
        try:
            _, rest = line.split(":", 1)
        except ValueError:
            continue
        parts = rest.strip().split()
        if not parts:
            continue
        iface = parts[0]
        if not (IFACE_TUN_RE.match(iface) or is_tunnel_iface(iface)):
            continue
        ips = IPV4_RE.findall(line)
        ip = next((i for i in ips if not i.startswith("0.")), "-")
        key = (iface, ip)
        if key not in seen:
            seen.add(key)
            found.append((iface, ip))
    return found

def pids_touching_iface_userland(iface: str):
    """Best-effort scan of /proc/*/{fdinfo,fd} without sudo."""
    pids = set()
    for pid_dir in glob.iglob("/proc/[0-9]*"):
        pid = int(pid_dir.rsplit("/", 1)[-1])
        found = False
        fdinfo_dir = os.path.join(pid_dir, "fdinfo")
        if os.path.isdir(fdinfo_dir):
            for fd in glob.iglob(os.path.join(fdinfo_dir, "*")):
                try:
                    with open(fd, "rt", errors="ignore") as fh:
                        if iface in fh.read():
                            pids.add(pid); found = True; break
                except Exception:
                    pass
        if not found:
            fd_dir = os.path.join(pid_dir, "fd")
            if os.path.isdir(fd_dir):
                for fd in glob.iglob(os.path.join(fd_dir, "*")):
                    try:
                        if iface in os.readlink(fd):
                            pids.add(pid); break
                    except Exception:
                        pass
    return sorted(pids)

def sudo_pids_touching_iface(iface: str):
    """Match Bash: sudo grep -r <iface> /proc/*/fdinfo | cut -d/ -f3 (non-interactive)."""

    # --- if sudo requires a TTY/password, this will just return empty.
    rc, _, _ = run(["sudo", "-n", "true"])
    if rc != 0:
        return []
    rc, out, _ = run(["bash", "-lc", f"sudo -n grep -r {sh_quote(iface)} /proc/*/fdinfo 2>/dev/null | cut -d/ -f3"])
    if rc != 0 or not out:
        return []
    pids = []
    for ln in out.splitlines():
        s = ln.strip()
        if s.isdigit():
            pids.append(int(s))
    return sorted(set(pids))

def pid_cmdline(pid: int) -> str:
    try:
        with open(f"/proc/{pid}/cmdline", "rb") as f:
            parts = [p.decode("utf-8", "replace") for p in f.read().split(b"\x00") if p]
            if parts:
                return " ".join(parts)
    except Exception:
        pass
    rc, out, _ = run(["ps", "-o", "cmd", "--no-headers", str(pid)])
    return out.strip() if rc == 0 else ""

def classify_provider(iface: str, cmds: str) -> str:
    """Provider-first; fall back to engines; then iface heuristics."""

    lname = iface.lower()
    s = cmds.lower()
    if "nordvpn" in s or "nordvpnd" in s or "nordtun" in lname or "nord" in lname:
        return "NordVPN"
    if "tailscaled" in s or "tailscale" in s or lname.startswith("tailscale"):
        return "Tailscale"
    if "zerotier" in s or lname.startswith("zt"):
        return "ZeroTier"
    if "protonvpn" in s or " pvpn " in s:
        return "ProtonVPN"
    if "mullvad" in s:
        return "Mullvad VPN"
    if "tryhackme" in s:
        return "TryHackMe"
    if "openvpn" in s:
        return "OpenVPNServer" if "server" in s else "OpenVPN"
    if "wg-quick" in s or "wireguard" in s or re.search(r"\bwg\d*\b", s):
        return "WireGuard"
    if "openconnect" in s or "ocserv" in s:
        return "OpenConnect/AnyConnect"
    if "charon" in s or "strongswan" in s or "ipsec" in s:
        return "IPsec/StrongSwan"
    if "pluto" in s or "libreswan" in s:
        return "IPsec/Libreswan"
    if "xl2tpd" in s:
        return "L2TP (xl2tpd)"
    if "pptp" in s:
        return "PPTP"
    if lname.startswith(("wg", "ppp", "vpn", "tun", "tap")):
        return {"wg": "WireGuard", "ppp": "PPP"}.get(lname[:3], "TUN/TAP")
    return "UNDEFINED"

def main():
    console = Console()

    # --- collect VPN/tunnel ifaces + IPs
    ifaces = list_vpn_ifaces()
    if not ifaces:
        console.print()
        console.print("[bold yellow][!][/bold yellow] NO TUNNELS, NOR VPN FOUND.")
        return 0

    # --- build rows: INT / IP / PID / NAME
    rows = []
    for iface, ip in ifaces:
        pids = pids_touching_iface_userland(iface)
        if not pids:
            pids = sudo_pids_touching_iface(iface)
        cmds_joined = " \n ".join(pid_cmdline(p) for p in pids) if pids else ""
        name = classify_provider(iface, cmds_joined)
        rows.append((iface, ip if ip else "-", ",".join(str(p) for p in pids) if pids else "-", name))

    # --- render table.
    table = Table(
        title="[*] Tunnels/VPN info",
        box=box.SIMPLE,
        show_lines=False,
        title_style="bold blue",
        title_justify="left",
    )
    table.add_column("INTERFACE")
    table.add_column("IP ADDR")
    table.add_column("PID")
    table.add_column("NAME")

    for INT, IP, PID, NAME in rows:
        table.add_row(INT, IP, PID, NAME)

    console.print(table)
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
