FROM python:3.8.12-slim-buster

# create app directory
RUN mkdir -p /usr/src/dark
WORKDIR /usr/src/dark

# copy requirements.txt to container
COPY requirements.txt /tmp/requirements.txt

# install dependencies
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

# clean
RUN rm /tmp/requirements.txt