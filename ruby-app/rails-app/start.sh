#!/bin/sh

rm /app/tmp/pids/server.pid
bundle exec rails db:setup
bundle exec rails db:migrate
bundle exec rails server -b 0.0.0.0
