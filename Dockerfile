FROM ruby:3.1-bullseye
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
