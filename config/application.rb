ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.

require "rails"
require "action_controller/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

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

    # Setup an in memory cache store.
    # Docs say: This cache has a bounded size specified by the :size options
    # to the initializer (default is 32Mb). When the cache exceeds the allotted
    # size, a cleanup will occur which tries to prune the cache down to three
    # quarters of the maximum size by removing the least recently used entries.
    config.cache_store = :memory_store
  end
end

# Initialize the Rails application.
Rails.application.initialize!

# Draw the routes for the application.
Rails.application.routes.draw do
  get "devices/:id/latest_timestamp", to: "devices#latest_timestamp"
  get "devices/:id/cumulative_count", to: "devices#cumulative_count"
  # I'm leaving this at /readings, but a more proper RESTful route would be
  # /devices/:id/readings -- but since the structure of the JSON has all the
  # required information, we can make things nicer for our client consumers.
  post "readings", to: "readings#create"
end
