#!/bin/bash

docker build --tag terraform-gen-docs .
docker run \
  --mount src="$(pwd)/provision",target=/input,type=bind \
  --mount src="$(pwd)/docs",target=/output,type=bind \
  terraform-gen-docs
