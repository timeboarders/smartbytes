#!/bin/bash

docker run -it --rm \
	-v "/home/$(whoami)/.smartcloud:/home/$(whoami)/.smartcloud" \
	-v "/var/run/docker.sock:/var/run/docker.sock" \
	-v "$PWD:$PWD" \
	-w "$PWD" \
	-u `id -u` \
	smartcloud "$@"
