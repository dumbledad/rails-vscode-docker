FROM ruby:3.0
RUN apt update
RUN apt upgrade --yes
RUN apt install --yes nodejs postgresql-client
WORKDIR /app
COPY Gemfile Gemfile.lock /app/
RUN bundle install
EXPOSE 3000
EXPOSE 1234
EXPOSE 26162

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

