# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Rails
rails_version = '~> 5.2'
gem 'actionpack', rails_version
gem 'activesupport', rails_version
gem 'railties', rails_version

# Utilities
gem 'chunky_png'
gem 'jwt'
gem 'typhoeus'

# Use Puma as the app server
gem 'puma', '~> 4.3'

# Include for Linux
gem 'tzinfo-data'

gem 'rubocop'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
end

group :test do
  gem 'rspec-rails'
  gem 'webmock'
end
