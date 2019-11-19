from flask import render_template
from flask_cors import CORS
from connexion.resolver import RestyResolver
import connexion

options = {"swagger_ui": True}

# Create the application instance
app = connexion.App(__name__, specification_dir='./')
CORS(app.app)

# Read the swagger.yml file to configure the endpoints
app.add_api('swagger.yml')

# Create a URL route in our application for "/"
@app.route('/')
def home():
    """
    This function just responds to the browser ULR
    localhost:5000/
    :return:        the rendered template 'home.html'
    """
    return render_template('home.html')

# If we're running in stand alone mode, run the application
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
