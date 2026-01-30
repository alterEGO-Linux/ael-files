#!/usr/bin/env python3
# ------------------------------------------------------------------------ INFO
# [/.ael/bin/convert-web-md.py]
# author        : Pascal Malouin @https://github.com/alterEGO-Linux
# created       : 2025-11-16 19:15:59 UTC
# updated       : 2026-01-30 19:34:09 UTC
# description   : Web to markdown converter.

"""
Download an HTML page and convert it to Markdown using pandoc.

Valid usage:
    python html_to_md.py --url URL --out output.md
    python html_to_md.py URL output.md

INVALID:
    python html_to_md.py output.md URL
"""

import argparse
import subprocess
import sys
import tempfile
from pathlib import Path

import requests


def download_html(url: str) -> str:
    """Download HTML content from a URL and return it as text."""
    try:
        header = {
            "User-Agent": "convert-web-md/1.0 (https://github.com/alterEGO-Linux;)"
        }
        resp = requests.get(url, headers=header, timeout=30)
        resp.raise_for_status()
    except requests.RequestException as e:
        print(f"[ERROR] Failed to download {url}: {e}", file=sys.stderr)
        sys.exit(1)
    return resp.text


def run_pandoc(html_path: Path, output_md: Path) -> None:
    """Run pandoc to convert html_path → output_md."""
    cmd = [
        "pandoc",
        "-f", "html",
        "-t", "gfm+pipe_tables",
        "--wrap=none",
        str(html_path),
        "-o", str(output_md),
    ]

    try:
        subprocess.run(cmd, check=True)
    except FileNotFoundError:
        print("[ERROR] pandoc not found. Install pandoc and try again.", file=sys.stderr)
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        print(f"[ERROR] pandoc failed with exit code {e.returncode}", file=sys.stderr)
        sys.exit(e.returncode)


def main():
    parser = argparse.ArgumentParser(
        description="Download an HTML page and convert it to Markdown using pandoc."
    )

    parser.add_argument("--url", help="URL to download (optional)")
    parser.add_argument("--out", help="Output Markdown file (optional)")

    # --- Positional arguments (optional if --url/--out are used)
    parser.add_argument("positional", nargs="*", help="Optional positional URL + output.md")

    args = parser.parse_args()

    # --- Case 1: Using --url and --out explicitly.
    if args.url and args.out:
        url = args.url
        output_md = Path(args.out).resolve()

    # --- Case 2: Using positional URL + output.md.
    elif len(args.positional) == 2:
        first, second = args.positional

        if first.lower().startswith("http"):
            # Valid: URL first, output second
            url = first
            output_md = Path(second).resolve()
        else:
            # --- Invalid order.
            print(
                "[ERROR] Invalid positional order.\n"
                "When using positional arguments, the URL must come first.\n\n"
                "Valid:   python html_to_md.py URL output.md\n"
                "Invalid: python html_to_md.py output.md URL",
                file=sys.stderr,
            )
            sys.exit(1)

    else:
        print(
            "[ERROR] You must specify either:\n"
            "  python html_to_md.py --url URL --out output.md\n"
            "OR\n"
            "  python html_to_md.py URL output.md\n",
            file=sys.stderr,
        )
        sys.exit(1)

    print(f"[INFO] Downloading HTML from: {url}")
    html_content = download_html(url)

    # --- Write to temporary file.
    with tempfile.NamedTemporaryFile(suffix=".html", delete=False) as tmp:
        html_path = Path(tmp.name)
        tmp.write(html_content.encode("utf-8"))
        print(f"[INFO] Saved HTML to: {html_path}")

    print(f"[INFO] Converting → {output_md}")
    run_pandoc(html_path, output_md)

    print(f"[OK] Markdown written to: {output_md}")

if __name__ == "__main__":
    main()
