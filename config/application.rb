require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module ClojuredocsPg
  class Application < Rails::Application
    config.secret_token = '4a0d577861650b391bcd71dbd12c11dd5e811c294f43c07cb352e8ab34c2c96a3292a8404b195ee6389c1c668fa670d2f207b278d9bae2c28b475beab2c2c438'
    config.autoload_paths += [config.root.join('lib')]
    config.encoding = 'utf-8'
    config.time_zone = 'UTC'
  
    config.filter_parameters += [:password, :password_confirmation]

    config.paths['db/migrate'] += Feedbacker::Engine.paths['db/migrate'].existent

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
    config.assets.initialize_on_precompile = false
  end
end
