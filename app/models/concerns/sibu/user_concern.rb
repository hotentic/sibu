module Sibu
  module UserConcern
    include ActiveSupport::Concern

    def for_user(usr)
      Rails.application.config.sibu[:multi_user] ? (shared + where(user_id: usr.id)) : all
    end

    def shared
      where(user_id: nil)
    end
  end
end