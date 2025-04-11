from flask import Flask, send_from_directory
from flask_cors import CORS
from services.db import DBManager
import os

# import of routes defined in the routes/ folder
from routes.test import test_routes
# ...

app = Flask(__name__)
CORS(app)

# register external routes
app.register_blueprint(test_routes)


# create a database connection and store it in the flask context
# now we can access it in any blueprint
db_manager = DBManager(os.environ.get('POSTGRES_DB'), os.environ.get('POSTGRES_USER'), os.environ.get('POSTGRES_PASS'), os.environ.get('DB_HOST'), 5432)
app.config['DB_MANAGER'] = db_manager


## default endpoints necessary for serving frontend data
@app.errorhandler(404)
def error404(e):
    return app.send_static_file('./index.html')

@app.route('/<path:path>', methods=['GET'])
def static_proxy(path):
  return send_from_directory('./static/', path)

@app.route('/')
def index():
    return app.send_static_file('./index.html')

# @app.route('/health')
# def health():
#     return 'OK'