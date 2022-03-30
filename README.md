# Debugging a Rails app running in Docker containers using VSCode

## Simple Rails in Docker

To get a simple vanilla Rails app up and running in a Docker container on your local machine follow [these instructions](SimpleRailsInDocker.md)

## Debuging with Visual Studio Code

The [Ruby on Rails debugging in VS Code](https://github.com/Microsoft/vscode-recipes/tree/master/debugging-Ruby-on-Rails) recipe on GitHub is about debuging on your local machine, not in Docker containers, but the [Bonus](https://github.com/Microsoft/vscode-recipes/tree/master/debugging-Ruby-on-Rails#bonus) content goes on to cover Docker. This bonus content details the following.

### The configuration to add to your [.vscode/launch.json](.vscode/launch.json) file

Add a configuration like this:

    {
        "name": "Rails Debug",
        "type": "Ruby",
        "request": "attach",
        "cwd": "${workspaceRoot}",
        "remoteWorkspaceRoot": "/app",
        "remoteHost": "0.0.0.0",
        "remotePort": "1234",
        "showDebuggerOutput": true
    }

### The matching changes to your [docker-compose.yml](docker-compose.yml) and [Dockerfile](Dockerfile) files

The port number in your [.vscode/launch.json](.vscode/launch.json) file will need to match the one specified in your [docker-compose.yml](docker-compose.yml) file. You will also need to make rails available for debugging, i.e. 

    app:
      build: .
      command: >
        bash -c "rm -f tmp/pids/server.pid && 
        # bundle exec rails server --port=3000 --binding='0.0.0.0'"
        bundle exec rdebug-ide --debug --host 0.0.0.0 --port 1234 -- rails s -p 3000 -b 0.0.0.0
      volumes:
        - .:/app
      ports:
        - "1234:1234"
        - "3000:3000"
        - "26162:26162"
      depends_on:
        - db
      environment:
        - POSTGRES_USER
        - POSTGRES_PASSWORD

N.B. The [Dockerfile](Dockerfile) needs to expose the same ports, e.g.

    EXPOSE 3000
    EXPOSE 1234
    EXPOSE 26162

### Problems

The Rails app starts without waiting for the debugger. Interestingly I can see this in the app log:

> Starting rails server without rdebug-ide  

That comes from the [entrypoint.sh](entrypoint.sh) file:

    if [ ${RDEBUG_IDE:-0} -eq 1 ]
    then
        echo "Starting rails server under rdebug-ide"
        rdebug-ide --skip_wait_for_start --host $HOST --port $DEBUG_PORT --dispatcher-port $DISPATCHER_PORT -- rails server --binding $HOST --port $PORT
    else
        echo "Starting rails server without rdebug-ide"
        rails server --binding $HOST --port $PORT
    fi

but in my .env file I have 

    RDEBUG_IDE=1
