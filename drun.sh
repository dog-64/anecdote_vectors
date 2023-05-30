#!/usr/bin/env bash
# запуск в production
#set -exuo pipefail

docker-compose stop redis
docker-compose down
docker-compose up -d
#mkdir -p ./log

#sleep 15
#curl http://localhost:3001/ping

docker-compose ps
docker-compose logs -f
