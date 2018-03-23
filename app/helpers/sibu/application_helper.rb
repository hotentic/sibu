module Sibu
  module ApplicationHelper
    def conf
      Rails.application.config.sibu
    end

    def sibu_user
      send(Rails.application.config.sibu[:current_user])
    end
  end
end
