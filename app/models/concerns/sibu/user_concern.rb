module Sibu
  module UserConcern
    include ActiveSupport::Concern

    def for_user(usr)
      Rails.application.config.sibu[:multi_user] ? where(user_id: [nil, usr.id]) : all
    end
  end
end