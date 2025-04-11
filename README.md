# GIS WS2324 Project Template

This repository serves as a starting point for the GIS application you are developing in the scope of the GIS tutorials.


## Forking

To be able to make changes to this code, you first need to create your own, private duplicate of this repository.
This can be achieved by *forking*. You can create your own fork by pressing the **Fork** button in the top right.

For more information, check out the [documentation](https://docs.gitlab.com/ee/user/project/repository/forking_workflow.html).


## Run

To start the application, simply navigate your console to this directory and type `docker-compose up` with [Docker](https://docs.docker.com/get-docker/) installed on your machine.

For Windows users, we encourage the usage of the [Windows Subsystem for Linux (WSL)](https://learn.microsoft.com/en-us/windows/wsl/install).

The application consists of an Angular `frontend`, python flask `backend`, and a PostGIS `database`.

The frontend of the application will be available on [localhost:4200](https://localhost:4200/).

The backend of the application will be available on [localhost:5000](https://localhost:5000/). 
A sample endpoint is already provided at [/test/dbtest](http://localhost:5000/test/dbtest).
