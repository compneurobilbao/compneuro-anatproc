FROM compneurobilbaolab/compneuro-anatproc:1.0

RUN echo "Done pulling compneuro-anatproc base image"

WORKDIR /app
COPY . /app
