FROM smartcloud:latest
LABEL maintainer="Timeboard <hello@timeboard.me>"

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

# Gems
RUN gem install bundler

CMD ["buildpacker", "pack"]
