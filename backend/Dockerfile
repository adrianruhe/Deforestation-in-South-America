# specify base image that we want to extend
FROM python:3.9-slim

# set environment variables
ENV POSTGRES_DB="johndoe_db"
ENV POSTGRES_USER="johndoe"
ENV POSTGRES_PASS="johndoe_pass"

ENV APP_DIR=/var/opt/gis
RUN mkdir -p ${APP_DIR}

# requirements first to use build caching
COPY ./requirements.txt ${APP_DIR}/requirements.txt

WORKDIR ${APP_DIR}

# install build-essentials
RUN apt-get update
RUN apt-get install -y build-essential

# install python dependencies
RUN pip3 install --upgrade pip
# installs every package listed in the requirements.txt file
RUN pip3 install -r requirements.txt

# copy application code
COPY . ${APP_DIR}

# environment variables
ENV FLASK_APP server.py
ENV FLASK_RUN_HOST 0.0.0.0
ENV FLASK_DEBUG 1
ENV JSON_AS_ASCII false
ENV PYTHONUNBUFFERED 1

# run flask server
CMD python -m flask run