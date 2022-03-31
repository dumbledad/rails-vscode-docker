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

The port number in your [.vscode/launch.json](.vscode/launch.json) file will need to match the one specified in your [docker-compose.yml](docker-compose.yml) file. You will also need to make rails available for debugging and the [Dockerfile](Dockerfile) needs to expose the same ports.

Between your [docker-compose.yml](docker-compose.yml) and [Dockerfile](Dockerfile) files you need to run the Rails server from `rdebug-ide`. For example:

#### Included in a [docker-compose.yml](docker-compose.yml) file

    app:
      build: .
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
        - RDEBUG_IDE

#### Included in a  [Dockerfile](Dockerfile)

    EXPOSE 3000
    EXPOSE 1234
    EXPOSE 26162

    COPY entrypoint.sh /usr/bin/
    RUN chmod +x /usr/bin/entrypoint.sh
    ENTRYPOINT ["entrypoint.sh"]

#### Included in the an [entrypoint.sh](entrypoint.sh) file

    HOST=0.0.0.0
    PORT=3000
    DEBUG_PORT=1234
    DISPATCHER_PORT=26162

    if [ ${RDEBUG_IDE:-0} -eq 1 ]
    then
        echo "Starting rails server under rdebug-ide"
        rdebug-ide --skip_wait_for_start --host $HOST --port $DEBUG_PORT --dispatcher-port $DISPATCHER_PORT -- ./bin/rails server --binding $HOST --port $PORT
    else
        echo "Starting rails server without rdebug-ide"
        rails server --binding $HOST --port $PORT
    fi

At that point you can set `RDEBUG_IDE` to `1` in your `.env` file (based on [[.env.example](.env.example)), run the container with `docker compose up`, and connect to the container in VSCode, setting breakpoints etc.
