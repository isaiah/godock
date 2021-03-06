ClojuredocsPg::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.action_controller.perform_caching             = true
  config.action_view.cache_template_loading            = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  #require 'active_support/cache/dalli_store23'
  #config.cache_store = :dalli_store

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  #
  config.serve_static_assets = false
  config.assets.compress = true
  config.assets.compile = false
  config.assets.digest = true

  config.eager_load = true

  # Enable threaded mode
  # config.threadsafe!
  config.middleware.use Rack::Cache,
    :verbose => true,
    :metastore   => "memcached://127.0.0.1:11211/meta",
    :entitystore => "memcached://127.0.0.1:11211/body"

  ROOT_URL = "http://www.godock.org"
end
