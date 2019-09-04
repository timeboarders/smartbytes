FROM ruby:2.6.4-alpine3.10
LABEL maintainer="Timeboard <hello@timeboard.me>"

# User
ARG USER_UID
ARG USER_NAME
RUN adduser --disabled-password --gecos "" --uid "$USER_UID" "$USER_NAME"

# Ruby on Rails Essentials
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

# Privileges
USER "$USER_NAME"
WORKDIR "/app"

# Gems
RUN gem install smartcloud && \
	gem install bundler && \
	gem install god

CMD ["buildpacker", "start"]
