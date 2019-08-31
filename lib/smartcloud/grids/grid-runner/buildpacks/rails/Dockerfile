FROM ruby:2.6.3-alpine
MAINTAINER Timeboard <hello@timeboard.me>

############### INSTALL RUBY ON RAILS ESSENTIALS ###############

RUN apk add --update tzdata && \
	apk add --update build-base && \
    rm -rf /var/cache/apk/*

# Install bundler and foreman gems
RUN gem install bundler && \
	gem install foreman

# Command to execute at container start
CMD ["ruby", "buildpacker.rb"]
