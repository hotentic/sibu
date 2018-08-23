module Sibu
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    before_action Rails.application.config.sibu[:auth_filter]

    def conf
      Rails.application.config.sibu
    end

    def sibu_user
      send(conf[:current_user])
    end
  end
end
