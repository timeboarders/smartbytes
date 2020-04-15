#!/bin/bash

docker run -it --rm \
	-v "/home/$(whoami)/.smartcloud:/home/$(whoami)/.smartcloud" \
	-v "/var/run/docker.sock:/var/run/docker.sock" \
	-w "/home/$(whoami)/.smartcloud" \
	-u `id -u` \
	--entrypoint "smartcloud" \
	smartcloud "$@"
