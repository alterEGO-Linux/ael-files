#!/usr/bin/env python3
import argparse
import sys
import requests
from typing import Tuple

# Try Rich
try:
    from rich.console import Console
    from rich.table import Table
    from rich.panel import Panel
    from rich import box
    from rich.rule import Rule
    HAS_RICH = True
    console = Console()
except Exception:
    HAS_RICH = False
    console = None

def translate(text: str, target_lang: str, source_lang: str = "auto") -> Tuple[str, str]:
    """Translate text using the unofficial Google endpoint. Returns (translation, detected_source_lang)."""
    url = "http://translate.googleapis.com/translate_a/single"
    params = {"client": "gtx", "sl": source_lang, "tl": target_lang, "dt": "t", "q": text}
    headers = {"User-Agent": "Mozilla/5.0"}
    resp = requests.get(url, params=params, headers=headers, timeout=15)
    resp.raise_for_status()
    data = resp.json()

    segments = data[0]
    translation = "".join(seg[0] for seg in segments if isinstance(seg, list) and seg and seg[0])
    detected = data[2] if len(data) > 2 and isinstance(data[2], str) else source_lang
    return translation, detected

def read_input_text(args_text):
    if args_text and args_text != ["-"]:
        return " ".join(args_text).strip()
    if not sys.stdin.isatty():
        piped = sys.stdin.read().strip()
        if piped:
            return piped
    sys.exit("No text provided.\nUse: translate.py 'hello world' --lang tl  OR  echo 'hello' | translate.py --tagalog")

def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(description="Translate text. Rich two-column table if available; plain otherwise.")
    p.add_argument("text", nargs="*", help="Text to translate. Use '-' to read from stdin.")

    g = p.add_mutually_exclusive_group()
    g.add_argument("--english", action="store_const", const="en", dest="lang", help="Translate to English (default)")
    g.add_argument("--tagalog", action="store_const", const="tl", dest="lang", help="Translate to Tagalog")
    g.add_argument("--french", action="store_const", const="fr", dest="lang", help="Translate to French")
    g.add_argument("--spanish", action="store_const", const="es", dest="lang", help="Translate to Spanish")
    g.add_argument("--lang", metavar="CODE", dest="lang", help="Target lang code (e.g., de, ja, it, pt, zh-CN, zh-TW)")

    p.add_argument("--sl", "--source-lang", dest="source_lang", default="auto", help="Source lang code (default: auto)")
    p.add_argument("--plain", action="store_true", help="Force plain output (ignore Rich even if installed).")
    p.add_argument("--result-only", action="store_true", help="Print only the translated text.")
    return p

def print_rich_table(original: str, src: str, translated: str, tgt: str):

    table = Table(show_header=False,
                  show_lines=True,
                  pad_edge=False,
                  show_edge=True,
                  box=box.MINIMAL,
                  border_style="cyan")

    table.add_column("Label", style="bold magenta", no_wrap=True)
    table.add_column("Text", style="white", overflow="fold")

    table.add_row(f"Original ({src})", original)
    table.add_row(f"Translation ({tgt})", translated)


    # Print a horizontal line of that width
    console.print(Rule(style="cyan"), end="")

    console.print(table)

    console.print(Rule(style="cyan"))

    # console.print(table)

def print_plain(original: str, src: str, translated: str, tgt: str):
    print(f"Original ({src}) :  {original}")
    print(f"Translation ({tgt}): {translated}")

def main():
    args = build_parser().parse_args()
    text = read_input_text(args.text)
    target_lang = args.lang or "en"

    try:
        translated, detected = translate(text, target_lang, source_lang=args.source_lang)
    except requests.HTTPError as e:
        print(f"HTTP error: {e.response.status_code} {e.response.reason}", file=sys.stderr)
        sys.exit(1)
    except requests.RequestException as e:
        print(f"Network error: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        sys.exit(1)

    if args.result_only:
        print(translated)
        return

    if HAS_RICH and not args.plain:
        print_rich_table(text, detected, translated, target_lang)
    else:
        print_plain(text, detected, translated, target_lang)

if __name__ == "__main__":
    main()
