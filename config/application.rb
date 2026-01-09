ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.

require "rails"
require "action_controller/railtie"
require "active_model/railtie"
require "active_record/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

ENV['DATABASE_URL'] = 'sqlite::memory:'

module Takehome
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # Eager load code on boot.
    config.eager_load = true

    config.consider_all_requests_local = true

    # Ensure our datastore is migrated.
    config.after_initialize do
      ActiveRecord::Base.connection.execute(<<~SQL)
        CREATE TABLE devices (
            id TEXT PRIMARY KEY,
            latest_timestamp DATETIME,
            cumulative_count INTEGER
        );

        CREATE TABLE readings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            device_id TEXT NOT NULL,

            count INTEGER,
            timestamp STRING,

            FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE
        );

        CREATE INDEX idx_readings_device_id ON readings(device_id);
      SQL
    end
  end
end

# Initialize the Rails application.
Rails.application.initialize!

# Draw the routes for the application.
Rails.application.routes.draw do
end
