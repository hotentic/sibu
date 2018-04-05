class CreateSibuDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :sibu_documents do |t|
      t.integer :user_id
      t.text :file_data

      t.timestamps
    end
  end
end
