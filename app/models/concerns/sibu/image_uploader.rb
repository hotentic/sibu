require "image_processing/mini_magick"

class Sibu::ImageUploader < Shrine
  include ImageProcessing::MiniMagick
  plugin :processing
  plugin :versions
  plugin :delete_raw

  process(:store) do |io, context|
    original = io.download
    images_config = Rails.application.config.sibu[:images]

    large = resize_to_limit!(original, images_config[:large], images_config[:large]) { |cmd| cmd.auto_orient }
    medium = resize_to_limit(large,  images_config[:medium], images_config[:medium])
    small = resize_to_limit(medium,  images_config[:small], images_config[:small])

    {original: io, large: large, medium: medium, small: small}
  end

  def generate_location(io, context)
    site_id  = context[:record].site_id
    style = context[:version] != :original ? "resized" : "originals"
    name  = super

    [site_id, style, name].compact.join("/")
  end
end