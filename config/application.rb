require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "action_controller/railtie"
require "action_view/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module OpenBadgeBakery
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    rsa_key = OpenSSL::PKey::RSA.new(2048)
    config.bakery = {
      default: {
        signing: {
          algorithm: 'RS256',
          private_key: rsa_key.to_pem,
          public_key: rsa_key.public_key.to_pem
        },
        images: {
          base_path: Rails.root.join('tmp')
        }
      }
    }
  end
end
