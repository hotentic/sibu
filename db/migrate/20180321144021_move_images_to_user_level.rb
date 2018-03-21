class MoveImagesToUserLevel < ActiveRecord::Migration[5.1]
  def change
    add_column :sibu_images, :user_id, :integer
    Sibu::Image.where("site_id IS NOT NULL").each {|img| img.update(user_id: img.site.user_id)}
    remove_column :sibu_images, :site_id
  end
end
