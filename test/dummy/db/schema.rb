# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190110204854) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "sibu_documents", force: :cascade do |t|
    t.integer "user_id"
    t.text "file_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sibu_images", force: :cascade do |t|
    t.text "metadata"
    t.text "file_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "sibu_pages", force: :cascade do |t|
    t.string "name"
    t.integer "site_id"
    t.text "metadata"
    t.string "path"
    t.string "template"
    t.jsonb "sections"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "custom_data"
  end

  create_table "sibu_site_templates", force: :cascade do |t|
    t.string "name"
    t.string "path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "default_sections"
    t.text "default_pages"
    t.text "default_templates"
    t.text "default_styles"
  end

  create_table "sibu_sites", force: :cascade do |t|
    t.string "name"
    t.integer "site_template_id"
    t.text "metadata"
    t.jsonb "sections"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "domain"
    t.text "custom_data"
    t.text "style_data"
    t.string "version"
  end

end
