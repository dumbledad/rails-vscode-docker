# Debugging a Rails app running in Docker containers using VSCode

## Log

- https://docs.docker.com/samples/rails/
- `docker compose run --no-deps app rails new . --force --database=postgresql`
  - https://docs.docker.com/compose/reference/run/
    - `--no-deps`: Don't start linked services 
  - https://guides.rubyonrails.org/command_line.html#rails-new
    - `--force`: Overwrite files that already exist
    - `--database`: Preconfigure for selected database (mysql/postgresql/sqlite3/oracle/sqlserver/jdbcmysql/jdbcsqlite3/jdbcpostgresql/jdbc)
