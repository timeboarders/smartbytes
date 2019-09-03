FROM ruby:2.6.4-alpine3.10
MAINTAINER Timeboard <hello@timeboard.me>

# Setting up user
# - envs
ARG USER_UID
ARG USER_NAME
# - Create user.
RUN adduser --disabled-password --gecos "" --uid "$USER_UID" "$USER_NAME"

# Install Ruby on Rails Essentials
RUN apk add --update build-base && \
	apk add --update tzdata && \
	apk add --update nodejs && \
	apk add --update yarn && \
	apk add --update mariadb-dev && \
	apk add --update imagemagick && \
	apk add --update ffmpeg && \
	apk add --update mupdf && \
	apk add --update mupdf-tools && \
    rm -rf /var/cache/apk/*

USER "$USER_NAME"

# Install gems
RUN gem install smartcloud && \
	gem install bundler && \
	gem install god

# Command to execute at container start
CMD ["buildpacker", "start"]
