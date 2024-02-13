FROM ruby:2.6.1-alpine

RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY app.rb ./

RUN chown -R appuser:appgroup /app

USER 1000

CMD ["ruby", "app.rb"]
