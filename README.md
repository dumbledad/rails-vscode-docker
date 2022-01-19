# Debugging a Rails app running in Docker containers using VSCode

## Simple Rails app in Docker containers

(This mostly follows the Docker [Quickstart: Compose and Rails](https://docs.docker.com/samples/rails/).)

Start by writing a `Dockerfile` to define the app:
```dockerfile
FROM ruby:3.1
RUN apt update
RUN apt upgrade --yes
RUN apt install --yes nodejs postgresql-client
WORKDIR /app
COPY Gemfile Gemfile.lock /app/
RUN bundle install

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]
```

We also need a simple `Gemfile` to get Rails started, and the presence of an empty `Gemfile.lock` file.

```gem
source 'https://rubygems.org'
gem 'rails', '~>7'
```

The `entrypoint.sh` is important, and is something we'll come back to when setting up VSCode debugging.
```bash
#!/bin/bash

# Cribbed from https://docs.docker.com/samples/rails/

# Exit immediately if a command returns a non-zero status.
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
```

We will use `docker compose` to build and run the containers. This is our `docker-compose.yml`
```yaml
---
version: '3.8'

services:

  db:
    image: postgres
    volumes:
      - ./tmp/db:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER
      - POSTGRES_PASSWORD

  app:
    build: .
    command: >
      bash -c "rm -f tmp/pids/server.pid && 
      bundle exec rails server --port=3000 --binding='0.0.0.0'"
    volumes:
      - .:/app
    ports:
      - "3000:3000"
    depends_on:
      - db
    environment:
      - POSTGRES_USER
      - POSTGRES_PASSWORD
```

You will notice that the `docker-compose.yml` file relies on environment variables for the Postgres username and password. Add a `.env` file with them defined in (see [Environment variables in Compose](https://docs.docker.com/compose/environment-variables/)).
```
POSTGRES_USER=postgres
POSTGRES_PASSWORD=password
```

Now we can run Rails to set up a skeleton app, using [`docker compose run`](https://docs.docker.com/compose/reference/run/):
```bash
docker compose run --no-deps web rails new . --force --database=postgresql
```
The `--no-deps` option means that only the container called _app_ is started, not those it depends on. That's the one with Rails in so `rails new . --force --database=postgresql` is executed in that container. (N.B. `--force` overwrites any files that already exist.)
## Log

- 
- `docker compose run --no-deps app rails new . --force --database=postgresql`
  - https://docs.docker.com/compose/reference/run/
    - `--no-deps`: Don't start linked services 
  - https://guides.rubyonrails.org/command_line.html#rails-new
    - `--force`: Overwrite files that already exist
    - `--database`: Preconfigure for selected database (mysql/postgresql/sqlite3/oracle/sqlserver/jdbcmysql/jdbcsqlite3/jdbcpostgresql/jdbc)
- https://docs.docker.com/compose/environment-variables/
