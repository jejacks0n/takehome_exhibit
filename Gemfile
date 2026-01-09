# frozen_string_literal: true

source "https://rubygems.org"

gem "rails", "~> 8.1"
gem "puma", "~> 7.1"

# I was going to just use an in memory data store, but thought maybe the exercise was meant
# to force me to implement it manually? I spiked on the solution with AR and migrating on
# server start with `ActiveRecord::Tasks::DatabaseTasks.migrate`. It was fine, and arguably
# sets the project up for better performance and flexibility with changing requirements.
# gem "sqlite3", ">= 2.1"

gem "standard", group: :development
gem "rspec-rails", groups: [:development, :test]
