module Sibu
  module UserConcern
    include ActiveSupport::Concern

    def for_user(usr)
      entities = (Rails.application.config.sibu[:multi_user] ? where(user_id: [nil, usr.id]) : all)
      entities.order(updated_at: :desc)
    end
  end
end