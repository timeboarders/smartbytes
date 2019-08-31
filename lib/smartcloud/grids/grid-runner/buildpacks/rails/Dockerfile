FROM ruby:2.6.4-alpine3.10
MAINTAINER Timeboard <hello@timeboard.me>

############### INSTALL RUBY ON RAILS ESSENTIALS ###############

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

# Install bundler and foreman gems
RUN gem install bundler && \
	gem install foreman

# Command to execute at container start
CMD ["ruby", "buildpacker.rb"]
