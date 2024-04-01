## ----------------------------------------------------------------------- INFO
## [run.py]
## author        : fantomH
## created       : 2024-01-06 15:40:18 UTC
## updated       : 2024-01-06 15:40:24 UTC
## description   : Launch app.

from app import (create_app)

if __name__ == "__main__":
    app = create_app()
    ## Using '0.0.0.0' enables the application to be available on other devices
    ## on the same network.
    app.run('0.0.0.0', port=5005, debug=True)

# vim: foldmethod=marker
## ------------------------------------------------------------- FIN ¯\_(ツ)_/¯
