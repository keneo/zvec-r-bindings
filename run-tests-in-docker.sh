#!/bin/bash
set -e
cd "$(dirname "$0")"

BUILD_ARGS=""
if [ "$1" = "--rebuild" ]; then
  BUILD_ARGS="--no-cache"
  echo "Full rebuild (ignoring Docker cache)..."
fi

docker build $BUILD_ARGS -t play-zvec-test -f docker/Dockerfile .
docker run --rm -v "$(pwd):/repo" play-zvec-test Rscript /repo/docker/test-all.R
