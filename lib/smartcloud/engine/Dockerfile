FROM ruby:2.6.4-alpine3.10
LABEL maintainer="Timeboard <hello@timeboard.me>"

# User
# --- Fix to change gid of 999 to 99 so that addgroup is free to create a group with 999 as gid
ARG USER_NAME
ARG USER_UID
ARG DOCKER_GID
RUN sed -i "s/999/99/" /etc/group && \
	adduser --disabled-password --gecos "" --uid "$USER_UID" "$USER_NAME" && \
	addgroup --gid "$DOCKER_GID" "docker" && adduser "$USER_NAME" "docker"

# Docker
RUN apk add --update docker && \
    rm -rf /var/cache/apk/*

# Smartcloud Gem
ARG SMARTCLOUD_VERSION
COPY ./smartcloud-$SMARTCLOUD_VERSION.gem ./smartcloud-$SMARTCLOUD_VERSION.gem
RUN gem install --no-document smartcloud-$SMARTCLOUD_VERSION.gem && \
	rm ./smartcloud-$SMARTCLOUD_VERSION.gem

ENTRYPOINT ["smartcloud"]
