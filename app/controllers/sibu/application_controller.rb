module Sibu
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    before_action Rails.application.config.sibu[:auth_filter]

    def sibu_user
      send(Rails.application.config.sibu[:current_user])
    end
  end
end
