class RenameUrlToPathInPages < ActiveRecord::Migration[5.1]
  def change
    rename_column :sibu_pages, :url, :path
  end
end
