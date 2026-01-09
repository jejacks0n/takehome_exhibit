FROM ruby:4.0.0-slim

RUN apt-get update -qq && \
    apt-get install -y build-essential libsqlite3-dev libyaml-dev git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /rails

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

# Expose the listening port, and run rackup directly.
EXPOSE 8000
CMD ["rackup", "config.ru", "-o", "0.0.0.0", "-p", "8000"]