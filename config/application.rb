require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ProductController
  class Application < Rails::Application
    # Initialize configuration defaults for Rails 8.1.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    config.autoload_lib(ignore: %w[assets tasks])

    config.autoload_paths += %W[#{config.root}/app/services]
    config.time_zone = "Tokyo"
    config.active_record.default_timezone = :local
    config.action_controller.raise_on_missing_callback_actions = false
  end
end
