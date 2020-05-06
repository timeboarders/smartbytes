#!/bin/bash

docker run -it --rm \
	-v "/home/$(whoami)/.smartmachine:/home/$(whoami)/.smartmachine" \
	-v "/var/run/docker.sock:/var/run/docker.sock" \
	-w "/home/$(whoami)/.smartmachine" \
	-u `id -u` \
	--entrypoint "smartmachine" \
	smartmachine "$@"
