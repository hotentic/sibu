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

    def check_site_ownership!
      if conf[:multi_user] && conf[:admin_filter]
        unless @site.nil? || @site.user_id == sibu_user.id || conf[:admin_filter].call(sibu_user)
          redirect_to main_app.root_url, alert: "Vous n'êtes pas autorisé(e) à consulter cette page."
        end
      end
    end
  end
end
