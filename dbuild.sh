#!/usr/bin/env bash
# построение образов и размещение их в docker registry
set -exuo pipefail
# чтобы без unbound variable
set +u

export BRANCH=$(git rev-parse --abbrev-ref HEAD)
export BUILD=$(curl -s https://increment.build/anecdote_vectors)
export COMPOSE_DOCKER_CLI_BUILD=0
export VARIANT=dockerhub.duletsky.ru/dostavka

echo "=== Сборка javascript и css"
rm -f public/packs/js/*.*
rm -f public/packs/css/*.*

echo "=== Для полной пересборки:"
echo "  BUILDKIT_PROGRESS=plain docker-compose up --force-recreate --build --remove-orphans --always-recreate-deps --renew-anon-volumes"
# docker-compose -f docker-compose-build.yml build

# для построения первого образа в ветке
# DOCKER_BUILDKIT=0 docker build \

docker-compose build
