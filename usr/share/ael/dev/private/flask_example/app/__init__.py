## ----------------------------------------------------------------------- INFO
## [app/__init__.py]
## author        : fantomH
## created       : 2024-01-06 15:42:52 UTC
## updated       : 2024-01-06 15:42:59 UTC
## description   : Application factory.

from flask import (Flask)
from flask_migrate import (Migrate)
from flask_sqlalchemy import (SQLAlchemy)
import os

db = SQLAlchemy()
migrate = Migrate()

def create_app():

    app = Flask(__name__, instance_relative_config=True)
    app.config.from_pyfile("config.py")

    ## ---------- ( VIEWS )

    from .routes.defaults import defaults
    app.register_blueprint(defaults, url_prefix="/")

    ## (* HTTP status codes *)
    """
    ## The error handlers for HTTP status codes are in .routes
    ## In order to work app-wide you must import them here.
    ## ref. https://flask.palletsprojects.com/en/2.2.x/errorhandling/
    """
    from .routes import not_found
    app.register_error_handler(404, not_found)

    ## ---------- ( DATABASE )
    #from .models import (Client)

    db.init_app(app)
    with app.app_context():
        if not os.path.exists("instance/" + app.config["DB_NAME"]):
            db.create_all()
            print("Created database!")

    migrate.init_app(app, db)

    return app

# vim: foldmethod=marker
## ------------------------------------------------------------- FIN ¯\_(ツ)_/¯
