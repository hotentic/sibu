require "shrine"
require "shrine/storage/file_system"

Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"),
    store: Shrine::Storage::FileSystem.new("public", prefix: "uploads/store"),
    styles_cache: Shrine::Storage::FileSystem.new("public", prefix: "stylesheets/cache"),
    styles_store: Shrine::Storage::FileSystem.new("public", prefix: "stylesheets/store")
}

Shrine.plugin :activerecord
Shrine.plugin :cached_attachment_data