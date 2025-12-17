#!/bin/bash
docker container run --rm --gpus all --shm-size=8gb --memory=8gb -p 5432:5432  --name=test1 -v $(pwd)/osmdata:/opt/osmdata -v $(pwd)/pgdata:/var/lib/pgsql/16/data -v $(pwd):/app -d mypg16-rocky9 
