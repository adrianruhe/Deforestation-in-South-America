# specify base image that we want to extend
FROM kartoza/postgis:16-3

# set environment variables
ENV POSTGRES_DB="johndoe_db"
ENV POSTGRES_USER="johndoe"
ENV POSTGRES_PASS="johndoe_pass"

# install required packages
RUN apt-get update && apt-get install -y gdal-bin 
RUN apt-get install -y postgis

# to parallelize
RUN apt-get install -y parallel  

# copy data into the docker container
COPY data /importdata

# when importing all squares
COPY data/lossyear_hansen /importdata/
COPY data/gain_hansen /importdata/

# FOR THE LANCZOS FILES:
# COPY data/treecover_lanczos /importdata/

# copies the init folder to the entrypoint of the docker container
# (all scripts will be executed when the container is build)
COPY init /docker-entrypoint-initdb.d