FROM ruby:2.5.1-alpine
MAINTAINER Timeboard <hello@timeboard.me>

############### INSTALL RUBY ON RAILS ESSENTIALS ###############

# Production variables for rails
ENV RAILS_ENV=production RACK_ENV=production RAILS_LOG_TO_STDOUT=enabled RAILS_SERVE_STATIC_FILES=enabled LANG=en_US.UTF-8

# mariadb-dev - required as replacement of libmysqlclient-dev in alpine
ENV BUILD_PACKAGES curl zlib zlib-dev readline yarn
ENV GEM_PACKAGES build-base linux-headers libxml2-dev libffi-dev libxslt-dev mysql-client mariadb-dev imagemagick nodejs

RUN apk update && apk upgrade && apk --no-cache add tzdata $BUILD_PACKAGES $GEM_PACKAGES; \
# Setting correct timezone
ln -fs /usr/share/zoneinfo/Asia/Kolkata /etc/localtime && apk del tzdata \
\
# Install bundler and foreman gems
gem install bundler; gem install foreman; \

# Generating entrypoint file
RUN echo -e '#!/bin/sh\n\
\n\
cd /code\n\
test -f ./tmp/pids/server.pid && rf ./tmp/pids/server.pid; true\n\
\n\
echo "----------------------------"\n\
echo "Performing Bundle Install"\n\
echo "----------------------------"\n\
bundle install\n\
echo "----------------------------"\n\
echo "Compiling Assets"\n\
echo "----------------------------"\n\
bundle exec rake assets:precompile\n\
\n\
exec "$@"' >> /entrypoint; chmod +x /entrypoint;

# Set entrypoint
ENTRYPOINT ["/entrypoint"]

# Command to execute at container start
CMD foreman start -f Procfile
