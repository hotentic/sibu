class AddStyleDataToSites < ActiveRecord::Migration[5.1]
  def change
    add_column :sibu_sites, :style_data, :text
  end
end
