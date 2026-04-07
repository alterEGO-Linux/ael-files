#!/usr/bin/env python
# ------------------------------------------------------------------------ INFO
# [/.ael/bin/geoip.py]
# author        : Pascal Malouin (https://github.com/alterEGO-Linux)
# created       : 2026-04-07 19:29:17 UTC
# updated       : 2026-04-07 19:29:17 UTC
# description   : Uses ip-api.com to output geolocalization info.

#!/usr/bin/env python3

import argparse
import ipaddress
import sys
import time

import requests

DEFAULT_FIELDS = [
    "query",
    "city",
    "regionName",
    "country",
    "lat",
    "lon",
    "timezone",
    "isp",
]

RATE_LIMIT_PER_MINUTE = 40
REQUEST_INTERVAL = 60.0 / RATE_LIMIT_PER_MINUTE


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Geolocate IP addresses one at a time."
    )

    parser.add_argument(
        "-f", "--file",
        help="File containing one IP per line",
    )
    parser.add_argument(
        "-i", "--ip",
        help="Single IP to query",
    )
    parser.add_argument(
        "-o", "--output",
        default=",".join(DEFAULT_FIELDS),
        help=f"Comma-separated output fields (default: {','.join(DEFAULT_FIELDS)})",
    )

    args = parser.parse_args()

    if args.file and args.ip:
        parser.error("use only one of -f/--file or -i/--ip")

    return args


def parse_fields(raw: str) -> list[str]:
    fields = [x.strip() for x in raw.split(",") if x.strip()]
    if not fields:
        raise ValueError("no output fields specified")
    return fields


def iter_ips(args: argparse.Namespace):
    if args.ip:
        yield args.ip.strip()
        return

    if args.file:
        with open(args.file, "r", encoding="utf-8") as f:
            for line in f:
                ip = line.strip().rstrip("\r")
                if not ip or ip.startswith("#"):
                    continue
                yield ip
        return

    if not sys.stdin.isatty():
        for line in sys.stdin:
            ip = line.strip().rstrip("\r")
            if not ip or ip.startswith("#"):
                continue
                yield ip
            yield ip
        return

    raise ValueError("no input provided; use -i, -f, or stdin")


def classify_ip(ip: str) -> tuple[bool, str]:
    try:
        addr = ipaddress.ip_address(ip)
    except ValueError:
        return False, "INVALID"

    if not addr.is_global:
        return False, "PRIVATE/LOCAL"

    return True, ""


def fetch_ip_data(ip: str, fields: list[str]) -> dict:
    url = f"http://ip-api.com/json/{ip}"
    params = {"fields": ",".join(["status", "message", *fields])}
    response = requests.get(url, params=params, timeout=5)
    response.raise_for_status()
    return response.json()


def make_error_row(ip: str, fields: list[str], message: str) -> list[str]:
    row = []
    for field in fields:
        if field == "query":
            row.append(ip)
        else:
            row.append(message)
    return row


def print_row(row: list[str], fields: list[str]) -> None:
    formatted = []

    for value, field in zip(row, fields):
        if field == "query":
            width = 17
        elif field == "city":
            width = 35
        else:
            width = 20

        formatted.append(f"{value:<{width}}")

    print(" ".join(formatted), flush=True)

def main() -> int:
    try:
        args = parse_args()
        fields = parse_fields(args.output)
    except Exception as e:
        print(f"[!] {e}", file=sys.stderr)
        return 1

    try:
        print_row(fields, fields)

        for ip in iter_ips(args):
            started = time.monotonic()

            ok, reason = classify_ip(ip)
            if not ok:
                print_row(make_error_row(ip, fields, reason))
            else:
                try:
                    data = fetch_ip_data(ip, fields)
                    if data.get("status") != "success":
                        message = str(data.get("message", "ERROR"))
                        print_row(make_error_row(ip, fields, message))
                    else:
                        row = [str(data.get(field, "")) for field in fields]
                        print_row(row, fields)
                except requests.RequestException as e:
                    print_row(make_error_row(ip, fields, f"REQUEST_ERROR: {e}"))

            elapsed = time.monotonic() - started
            sleep_for = REQUEST_INTERVAL - elapsed
            if sleep_for > 0:
                time.sleep(sleep_for)

    except BrokenPipeError:
        return 0
    except Exception as e:
        print(f"[!] {e}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
