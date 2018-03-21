module Sibu
  module UserConcern
    include ActiveSupport::Concern

    def for_user(usr)
      where(user_id: usr.id)
    end
  end
end