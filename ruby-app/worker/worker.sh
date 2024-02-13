#!/bin/sh

while true; do
  conn=${DATABASE_URL}
  updated_at=$(date)
  sql="UPDATE dummies SET message='Message updated at: ${updated_at}'"
  psql ${conn} -c "${sql}"
  sleep 10
done
