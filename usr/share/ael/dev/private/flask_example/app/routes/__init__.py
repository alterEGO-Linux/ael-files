## ----------------------------------------------------------------------- INFO
## [app/routes/__init__.py]
## author        : fantomH
## created       : 2024-01-06 15:53:46 UTC
## updated       : 2024-01-06 15:53:53 UTC
## description   : Basic routes.

from flask import (Blueprint,
                   current_app)

## ---------- ( STATUS )
status = Blueprint("status", __name__)

## (* 404 *)
@status.errorhandler(404)
def not_found(e):
    title = "404"
    return "NOT FOUND (404)"
    # return render_template("status/404.html", title=title)

# vim: foldmethod=marker
## ------------------------------------------------------------- FIN ¯\_(ツ)_/¯
