FROM ruby:2.7.1-alpine

ENV APP_PATH /var/app
ENV BUNDLE_VERSION 2.1.4
ENV BUNDLE_PATH /usr/local/bundle/gems
ENV TMP_PATH /tmp/
ENV APP_PORT 9293
ENV APP_CLIENT_PORT 9292

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN apk -U add --no-cache \
    build-base \
    git \
    libxml2-dev \
    libxslt-dev \
    sqlite-dev \
    tzdata \
    less \
    curl \
    bash \
    && rm -rf /var/cache/apk/* \
    && mkdir -p $APP_PATH

RUN gem install bundler --version "$BUNDLE_VERSION" \
    && rm -rf $GEM_HOME/cache/*

WORKDIR $APP_PATH

EXPOSE $APP_PORT
EXPOSE $APP_CLIENT_PORT

ENTRYPOINT [ "bundle", "exec" ]