require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Myapp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # config.x.fortune_api_url = 'https://app-api.rensa.jp.net:443/capo/'
    config.x.fortune_api_url = 'https://api-test-new.rensa.jp.net:443/capo/'
    config.x.fortune_api_user = 'rensa'
    config.x.fortune_api_pass = 'Rk8hGX3v'
    config.x.fortune_api_app_name = 'LUN'

    # auto load lib
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

  end
end
