FROM docker:latest
MAINTAINER Timeboard <hello@timeboard.me>

# Setting up group and user
# - envs
ARG DOCKER_GID
ARG USER_UID
ARG USER_NAME
# - fix to change gid of 999 to 99 so that addgroup is free to create a group with 999 as gid
# - Create group & user. Then add user to group
RUN sed -i "s/999/99/" /etc/group && \
	addgroup --gid "$DOCKER_GID" "docker" && \
	adduser --disabled-password --gecos "" --uid "$USER_UID" "$USER_NAME" && \
	adduser "$USER_NAME" "docker"

# We need the following:
# - fcgiwrap, because that is how nginx does CGI
# ----- IMPORTANT NOTE: This is custom build fcgiwrap package to account for NO_BUFFERING option.
# ----- Original fcgiwrap: https://github.com/gnosek/fcgiwrap
# ----- Custom fcgiwrap: https://github.com/notr1ch/fcgiwrap
# - git and git-daemon, because that gets us the git-http-backend CGI script
# - ruby, to run smartcloud gem
# - spawn-fcgi, to launch fcgiwrap and to create the unix socket
COPY fcgiwrap /root/apk-packages/fcgiwrap
RUN apk add fcgiwrap --repository /root/apk-packages/fcgiwrap/packages/main --allow-untrusted && \
	rm -rf /root/apk-packages
RUN apk add --update coreutils && \
	apk add --update util-linux && \
	apk add --update git && \
	apk add --update git-daemon && \
	apk add --update ruby && \
    apk add --update spawn-fcgi && \
    rm -rf /var/cache/apk/*

RUN gem install smartcloud --no-rdoc --no-ri

CMD "git, fcgiwrap & spawn-fcgi installed"
