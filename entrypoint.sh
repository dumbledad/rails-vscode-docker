#!/bin/bash

# Cribbed from https://docs.docker.com/samples/rails/

# Exit immediately if a command returns a non-zero status.
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

# Set variables
HOST=0.0.0.0
PORT=3000
DEBUG_PORT=1234
DISPATCHER_PORT=26162

# Start the debugging session for the Rails app if required
if [ ${RDEBUG_IDE:-0} -eq 1 ]
then
    echo "Starting rails server under rdebug-ide"
    rdebug-ide --skip_wait_for_start --host $HOST --port $DEBUG_PORT --dispatcher-port $DISPATCHER_PORT -- ./bin/rails server --binding $HOST --port $PORT
else
    echo "Starting rails server without rdebug-ide"
    rails server --binding $HOST --port $PORT
fi
