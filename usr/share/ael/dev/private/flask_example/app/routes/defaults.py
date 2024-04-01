## ----------------------------------------------------------------------- INFO
## [app/routes/defaults.py]
## author        : fantomH
## created       : 2024-01-07 03:10:55 UTC
## updated       : 2024-01-07 03:10:55 UTC
## description   : Default routes.

from flask import (Blueprint,
                   flash,
                   redirect,
                   render_template,
                   request,
                   url_for)

from .. import (db)

defaults = Blueprint("defaults", __name__)

## ---------- ( ROUTES )

@defaults.route('/', methods=['GET', 'POST'])
def home():

    title = "Home"

    return render_template('index.html', title=title)

# vim: foldmethod=marker
## ------------------------------------------------------------- FIN ¯\_(ツ)_/¯
