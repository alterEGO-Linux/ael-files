# ------------------------------------------------------------------------ INFO
# [ael-files/bin/convert-toml-json.py]
# author        : Pascal Malouin @https://github.com/alterEGO-Linux
# created       : 2025-12-28 19:29:25 UTC
# updated       : 2025-12-28 19:29:25 UTC
# description   : Convert TOML -> JSON

import tomllib, json, sys

p=sys.argv[1]

print(json.dumps(tomllib.load(open(p,"rb")), ensure_ascii=False))
