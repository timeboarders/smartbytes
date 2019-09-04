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

# FCGI Essentials
# --- IMPORTANT NOTE: This is custom built fcgiwrap package for alpine linux to account for NO_BUFFERING option.
# --- Original fcgiwrap: https://github.com/gnosek/fcgiwrap
# --- Custom fcgiwrap: https://github.com/notr1ch/fcgiwrap
COPY fcgiwrap /root/apk-packages/fcgiwrap
RUN apk add fcgiwrap --repository /root/apk-packages/fcgiwrap/packages/main --allow-untrusted && \
	rm -rf /root/apk-packages
RUN apk add --update coreutils && \
	apk add --update util-linux && \
	apk add --update docker && \
	apk add --update git && \
	apk add --update git-daemon && \
    apk add --update spawn-fcgi && \
    rm -rf /var/cache/apk/*

# Privileges
USER "$USER_NAME"
WORKDIR "/home/$USER_NAME/.smartcloud/grids/grid-runner/apps"

# Gems
RUN gem install smartcloud

CMD ["spawn-fcgi", "-n", "-p", "9000", "/usr/bin/fcgiwrap", "-f"]
