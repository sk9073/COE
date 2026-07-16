FROM ruby:3.2.10

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    postgresql-client

WORKDIR /app
COPY Gemfile Gemfile.lock ./

RUN bundle install
COPY . .

# 7. Add a script to be executed every time the container starts to fix Rails server pid issues
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# 8. Expose the port the Rails API runs on
EXPOSE 3000

# 9. Start the main process
CMD ["rails", "server", "-b", "0.0.0.0"]