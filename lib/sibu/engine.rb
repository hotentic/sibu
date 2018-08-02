require 'jquery-rails'

module Sibu
  class Engine < ::Rails::Engine
    isolate_namespace Sibu
    config.assets.paths << File.expand_path("../../assets/fonts", __FILE__)
    config.to_prepare do
      begin
        # Load custom helper if defined
        ApplicationController.helper(SibuCustomHelper)
      rescue
        Rails.logger.info("Sibu custom helper is not available - skipping")
      end
    end
  end
end
