FROM compneurobilbaolab/compneuro-anatproc:1.1

RUN echo "Done pulling compneuro-anatproc base image"

WORKDIR /app
COPY . /app
