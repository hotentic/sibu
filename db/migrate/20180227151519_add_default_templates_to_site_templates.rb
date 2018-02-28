class AddDefaultTemplatesToSiteTemplates < ActiveRecord::Migration[5.1]
  def change
    add_column :sibu_site_templates, :default_templates, :text
  end
end
