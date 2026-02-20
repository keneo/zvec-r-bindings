#!/bin/bash
set -e
cd "$(dirname "$0")"

if ! docker image inspect play-zvec-test > /dev/null 2>&1; then
  echo "Building play-zvec-test image..."
  docker build -t play-zvec-test docker/
fi

docker run --rm -v "$(pwd):/repo" play-zvec-test Rscript /repo/docker/test-all.R
