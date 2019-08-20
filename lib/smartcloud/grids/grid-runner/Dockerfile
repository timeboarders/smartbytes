FROM docker:latest
MAINTAINER Timeboard <hello@timeboard.me>

# We need the following:
# - git, because that gets us the git-http-backend CGI script
# - fcgiwrap, because that is how nginx does CGI
# - spawn-fcgi, to launch fcgiwrap and to create the unix socket
RUN apk add --update git && \
	apk add --update git-daemon && \
	apk add --update ruby && \
    apk add --update fcgiwrap && \
    apk add --update spawn-fcgi && \
    rm -rf /var/cache/apk/*

RUN gem install smartcloud --no-rdoc --no-ri

# launch fcgiwrap via spawn-fcgi; launch nginx in the foreground
# so the container doesn't die on us; supposedly we should be
# using supervisord or something like that instead, but this
# will do
CMD "git, fcgiwrap & spawn-fcgi installed"
