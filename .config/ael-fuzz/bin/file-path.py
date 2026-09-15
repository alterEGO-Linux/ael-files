#!/usr/bin/env python3

"""Produce AEL//Fuzz JSONL candidates from the current directory."""

import json
from pathlib import Path


for path in sorted(Path.cwd().iterdir(), key=lambda item: item.name.lower()):
    # Behave like ordinary `ls`: do not include hidden entries.
    if path.name.startswith("."):
        continue

    candidate = {
        # Resolve the path because the output add-on may run independently of
        # how the candidate was originally displayed.
        "value": str(path.resolve()),
        "display": path.name,
        "meta": {
            "path": str(path.resolve()),
            "kind": (
                "directory"
                if path.is_dir()
                else "file"
                if path.is_file()
                else "other"
            ),
        },
    }

    # JSON Lines allows filenames containing spaces, quotes, or Unicode.
    print(json.dumps(candidate, ensure_ascii=False))
