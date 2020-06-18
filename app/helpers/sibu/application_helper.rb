module Sibu
  module ApplicationHelper
    def conf
      Rails.application.config.sibu
    end

    def sibu_user
      send(conf[:current_user])
    end
  end
end
