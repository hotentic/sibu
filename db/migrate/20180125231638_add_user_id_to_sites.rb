class AddUserIdToSites < ActiveRecord::Migration[5.1]
  def change
    add_column :sibu_sites, :user_id, :integer
  end
end
