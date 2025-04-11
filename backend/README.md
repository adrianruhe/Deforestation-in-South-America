# BACKEND

This folder contains the code for the backend of the application, running a [flask](https://flask.palletsprojects.com/en/3.0.x/) environment.
Flask is a lightweight and flexible web application framework written in Python that allows you to fetch data from external sources or a database, preprocess the data and serve it to your frontend. 

## Application

The `server.py` file constitutes the heart of the application and creates the flask application, which will run on the port specified in the `../docker-compose.yaml` file (typically 5000). Here You can define routes that can be called (e.g. type `http://localhost:5000/health` in your browser when the application is running) to serve resources.

For better structuring of your code, I advise to make use of [flask blueprints](https://flask.palletsprojects.com/en/3.0.x/blueprints/). Instead of writing all your code in one single file, you can organize the different building blocks of your application in several files. Check out the `routes/test.py` file on how to do so. Current available routes are [http://localhost:5000/test/basic](http://localhost:5000/test/basic) and [http://localhost:5000/test/dbtest](http://localhost:5000/test/dbtest).

## Adding Packages

If you want to make use of additional external libraries, make sure to add the package name to the `requirements.txt` file, and rebuild the Docker container (`docker-compose build backend`). Some essential packages ([flask](https://flask.palletsprojects.com/en/3.0.x/), [numpy](https://numpy.org/), [pandas](https://pandas.pydata.org/), ...) are already installed by default.