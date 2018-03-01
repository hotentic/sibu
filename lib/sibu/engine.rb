require 'jquery-rails'

module Sibu
  class Engine < ::Rails::Engine
    isolate_namespace Sibu
    config.assets.paths << File.expand_path("../../assets/fonts", __FILE__)
  end
end
