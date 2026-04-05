#!/bin/bash
# Start PostgreSQL on container start (services don't auto-start from prebuilt images)
echo "Starting PostgreSQL..."
sudo service postgresql start

for i in {1..30}; do
  if pg_isready -h 127.0.0.1 -p 5432 > /dev/null 2>&1; then
    echo "PostgreSQL is ready"
    break
  fi
  sleep 1
done
