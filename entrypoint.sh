#!/bin/bash

# Cribbed from https://docs.docker.com/samples/rails/

# Exit immediately if a command returns a non-zero status.
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
