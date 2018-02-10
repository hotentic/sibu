class RenameImagesUserIdToSiteId < ActiveRecord::Migration[5.1]
  def change
    rename_column :sibu_images, :user_id, :site_id
  end
end
