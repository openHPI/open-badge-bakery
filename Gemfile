source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Rails
rails_version = '~> 5.2'
gem 'activesupport', rails_version
gem 'actionpack', rails_version
gem 'railties', rails_version

# Utilities
gem 'chunky_png'
gem 'jwt'
gem 'typhoeus'

# Use Puma as the app server
gem 'puma', '~> 3.12'

# Include for Linux
gem 'tzinfo-data'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
end

group :test do
  gem 'rspec-rails'
  gem 'webmock'
end
