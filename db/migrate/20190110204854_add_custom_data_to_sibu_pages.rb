class AddCustomDataToSibuPages < ActiveRecord::Migration[5.1]
  def change
    add_column :sibu_pages, :custom_data, :text
  end
end
