module Sibu
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    before_action Rails.application.config.sibu_auth_filter
  end
end
