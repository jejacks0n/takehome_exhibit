# This file is used by Rack-based servers to start the application.

# Load the Rails application.
require_relative "config/application"

run Rails.application
Rails.application.load_server
