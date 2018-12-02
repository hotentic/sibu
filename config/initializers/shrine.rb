require "shrine"
require "shrine/storage/file_system"
require "mini_magick"

Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"),
    store: Shrine::Storage::FileSystem.new("public", prefix: "uploads/store"),
    styles_cache: Shrine::Storage::FileSystem.new("public", prefix: "stylesheets/cache"),
    styles_store: Shrine::Storage::FileSystem.new("public", prefix: "stylesheets/store"),
    documents_cache: Shrine::Storage::FileSystem.new("public", prefix: "documents/cache"),
    documents_store: Shrine::Storage::FileSystem.new("public", prefix: "documents/store")
}

Shrine.plugin :activerecord
Shrine.plugin :cached_attachment_data

MiniMagick.configure do |config|
  config.whiny = false
end