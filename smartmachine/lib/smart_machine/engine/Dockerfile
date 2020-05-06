FROM ruby:2.7.0-alpine3.11
LABEL maintainer="Timeboard <hello@timeboard.me>"

# User
# --- Fix to change gid of 999 to 99 so that addgroup is free to create a group with 999 as gid
ARG USER_NAME
ARG USER_UID
ARG DOCKER_GID
RUN sed -i "s/999/99/" /etc/group && \
	adduser --disabled-password --gecos "" --uid "$USER_UID" "$USER_NAME" && \
	addgroup --gid "$DOCKER_GID" "docker" && adduser "$USER_NAME" "docker"

# Essentials
RUN apk add --update build-base && \
	apk add --update docker && \
	apk add --update git && \
    rm -rf /var/cache/apk/*

# smartmachine gem
ARG SMARTMACHINE_VERSION
COPY ./smartmachine-$SMARTMACHINE_VERSION.gem ./smartmachine-$SMARTMACHINE_VERSION.gem
RUN gem install --no-document smartmachine-$SMARTMACHINE_VERSION.gem && \
	rm ./smartmachine-$SMARTMACHINE_VERSION.gem

# smartmachine master key
ARG SMARTMACHINE_MASTER_KEY
ENV SMARTMACHINE_MASTER_KEY=$SMARTMACHINE_MASTER_KEY
