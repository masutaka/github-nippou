FROM ruby:2.4-alpine
LABEL maintainer "masutaka.net@gmail.com"

ENV VERSION=3.0.0

RUN apk add --update --no-cache git && \
    gem install -N github-nippou -v ${VERSION}

ENTRYPOINT ["github-nippou"]
