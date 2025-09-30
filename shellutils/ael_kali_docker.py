import os
import shlex
import shutil
import subprocess
import sys
import tempfile
import textwrap

def run(cmd, **kw):
    """Run a command with pretty logging and check=True by default."""
    print(f"[+] $ {' '.join(shlex.quote(c) for c in cmd)}")
    return subprocess.run(cmd, check=True, **kw)


def main():
    # Ensure Docker exists
    if not shutil.which("docker"):
        print("[!] docker is not installed or not in PATH.", file=sys.stderr)
        sys.exit(1)

    display = os.environ.get("DISPLAY", ":0")

    # Prepare Dockerfile text (fixed heredoc)
    dockerfile_text = '''\
FROM kalilinux/kali-rolling:latest

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

RUN bash <<'PKG'
set -euxo pipefail
apt-get update
apt-get -y upgrade
apt-get -y install \
  kali-linux-headless \
  kali-desktop-xfce \
  xserver-xephyr \
  dbus \
  dbus-x11 \
  gvfs \
  gvfs-daemons \
  udisks2 \
  polkitd \
  pkexec
apt-get clean
rm -rf /var/lib/apt/lists/*
PKG

WORKDIR /root

RUN python3 <<'EOL' >> /root/.bashrc
x = f"""
startx() {{
    [[ -e /tmp/.X2-lock ]] && rm -f /tmp/.X2-lock

    if ! pgrep -x dbus-daemon >/dev/null; then
        dbus-daemon --system --fork
    fi
    # Ensure session bus exists for this shell
    if [ -z "${{DBUS_SESSION_BUS_ADDRESS:-}}" ]; then
        eval "$(dbus-launch --sh-syntax)"
    fi
    if ! pgrep -x Xephyr >/dev/null; then
        Xephyr -br -ac -noreset -screen 1280x720 :2 &
    else
        echo 'Xephyr already running...'
    fi
    DISPLAY=:2 startxfce4 &
    wait
    pkill -x Xephyr || true
}}

close-gui() {{
    pkill -x Xephyr || true
}}
"""
print(x)
EOL

ENTRYPOINT ["/bin/bash"]
    '''

    # Best-effort: allow local root to connect to X (X11)
    try:
        subprocess.run(
            ["xhost", "+SI:localuser:root"],
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except FileNotFoundError:
        pass

    # If systemd is present, try starting docker.service (best-effort)
    if shutil.which("systemctl"):
        subprocess.run(["sudo", "systemctl", "start", "docker.service"], check=False)

    with tempfile.TemporaryDirectory() as tmp:
        dockerfile = os.path.join(tmp, "Dockerfile")
        with open(dockerfile, "w", encoding="utf-8") as f:
            f.write(dockerfile_text)

        # If container exists, start it; else build+run
        ps = subprocess.run(
            ["docker", "ps", "-a", "--filter", "name=^/KALI$", "-q"],
            capture_output=True,
            text=True,
            check=False,
        )
        try:
            if ps.stdout.strip():
                run(["docker", "start", "-i", "KALI"])
            else:
                # You can enable BuildKit by exporting DOCKER_BUILDKIT=1 in your env if you like.
                run(["docker", "build", "--network=host", "-f", dockerfile, "-t", "kali", tmp])
                run([
                    "docker", "run", "--name", "KALI",
                    "--net=host", "--privileged", "-it",
                    "-e", f"DISPLAY={display}",
                    "-e", "XAUTHORITY=/root/.Xauthority",
                    "-v", "/tmp/.X11-unix:/tmp/.X11-unix:rw",
                    "-v", f"{os.path.expanduser('~')}/.Xauthority:/root/.Xauthority:rw",
                    "kali",
                ])
        finally:
            # Revoke the xhost grant (best-effort)
            try:
                subprocess.run(
                    ["xhost", "-SI:localuser:root"],
                    check=False,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
            except FileNotFoundError:
                pass

if __name__ == "__main__":
    main()
