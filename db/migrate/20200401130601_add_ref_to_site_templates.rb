class AddRefToSiteTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :sibu_site_templates, :ref, :string
  end
end
