#!/bin/bash

docker build --tag terraform-gen-docs .
docker run \
  --mount src="$(pwd)/modules",target=/modules,type=bind \
  terraform-gen-docs
