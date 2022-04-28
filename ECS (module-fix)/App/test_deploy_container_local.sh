#!/bin/bash

docker build . -t app
docker run -it -p 8080:8080 app
open http://localhost:8080
