source 'http://rubygems.org'

group :assets do
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', '~> 0.10.2', :platforms => :ruby

  gem 'jquery-ui-rails'
  gem 'sass-rails'

  gem 'uglifier', '>= 1.0.3'
  gem 'zurb-foundation', '~> 4.0.0'
  gem 'font-awesome-rails'
end

gem 'jquery-rails'
gem 'rails', '~> 4.0.0'
gem 'ruby-openid'
gem 'rack-openid', :require => nil
gem "pg_search"
gem 'dalli'
gem 'rack-cache'
#gem 'acts_as_commentable_with_threading'
gem 'acts_as_versioned', github: "jwhitehorn/acts_as_versioned"
gem 'acts_as_voteable', github: 'zonecheung/acts_as_voteable'

platform :mri do
  gem 'rdiscount', '1.6.5'
  gem 'unicorn'
  gem "pg"
  gem 'psych'
end

platform :jruby do
  gem 'kramdown'
  gem 'jubilee'
  gem 'pg_jruby'
end

gem 'chronic', '0.2.3'
gem 'will_paginate'
#gem 'levenshtein', '0.2.0'
gem 'haml'

group :development do
  gem 'pry'
  gem 'better_errors'
  gem 'capistrano'
end

#group :production do
#  gem 'newrelic_rpm'
#end

group :test do
  gem 'shoulda', '2.11.3'
  gem 'flexmock', '0.8.7'
  #gem 'ZenTest', '4.4.0'
  gem 'rcov', '0.9.9', :require => nil
  #gem 'ruby-prof', '0.9.2'
end

gem 'angularjs-rails'

gem 'devise'
gem "devise_openid_authenticatable"
gem 'feedbacker'
