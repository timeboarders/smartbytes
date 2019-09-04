FROM ruby:2.6.4-alpine3.10
MAINTAINER Timeboard <hello@timeboard.me>

RUN apk add --update docker && \
    rm -rf /var/cache/apk/*

# Setting up group and user
# - envs
ARG USER_NAME
ARG USER_UID
ARG USER_GID
ARG DOCKER_GID
# - fix to change gid of 999 to 99 so that addgroup is free to create a group with 999 as gid
# - Create group & user. Then add user to group
RUN sed -i "s/999/99/" /etc/group && \
	adduser --disabled-password --gecos "" --uid $USER_UID --gid $USER_GID $USER_NAME && \
	addgroup --gid $DOCKER_GID "docker" && adduser $USER_NAME docker

USER "$USER_NAME"
WORKDIR "/home/$USER_NAME/.smartcloud"

# Generating entrypoint file
RUN echo -e '#!/bin/sh\n\
gem install --no-document smartcloud\n\
exec smartcloud "$@"' >> "/home/$(whoami)/entrypoint"; chmod +x "/home/$(whoami)/entrypoint"

# Set entrypoint
ENTRYPOINT "/home/$(whoami)/entrypoint"
