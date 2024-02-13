FROM ruby:2.7.1-alpine

# Install pre-requisites for building nokogiri & pg gems
RUN apk --update add --virtual build_deps \
    build-base ruby-dev libc-dev linux-headers \
    openssl-dev postgresql-dev libxml2-dev libxslt-dev

RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup

WORKDIR /app

COPY Gemfile* ./
RUN gem install bundler:2.2.4
RUN bundle install

COPY . .

# I have no idea why, but docker running in github actions skips the `tmp`
# directory when it runs the `COPY . .` line above
RUN mkdir -p /app/tmp/storage

RUN chown -R appuser:appgroup /app/tmp
RUN chown -R appuser:appgroup /app/log
RUN chown -R appuser:appgroup /app/db
RUN chown -R appuser:appgroup /app/Gemfile.lock

USER 1000

CMD ["rails", "server", "-b", "0.0.0.0"]
