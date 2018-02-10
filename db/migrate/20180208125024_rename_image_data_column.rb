class RenameImageDataColumn < ActiveRecord::Migration[5.1]
  def change
    rename_column :sibu_images, :data, :file_data
  end
end
