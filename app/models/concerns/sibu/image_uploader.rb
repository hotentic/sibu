require "image_processing/mini_magick"

class Sibu::ImageUploader < Shrine
  # include ImageProcessing::MiniMagick
  # plugin :versions
  # plugin :delete_raw

  Attacher.derivatives do |original|
    magick = ImageProcessing::MiniMagick.source(original)
    images_config = Rails.application.config.sibu[:images]
    image_type = original.path.ends_with?('.svg') ? "image/svg+xml" : "image"

    if image_type == "image/svg+xml"
      {large: original, medium: original, small: original}
    else
      {
        large:  magick.resize_to_limit!(images_config[:large], images_config[:large]) {|cmd| cmd.auto_orient},
        medium: magick.resize_to_limit!(images_config[:medium], images_config[:medium]),
        small:  magick.resize_to_limit!(images_config[:small], images_config[:small]),
      }
    end
  end

  # process(:store) do |io, context|
  #   original = io.download
  #   images_config = Rails.application.config.sibu[:images]
  #   image_type = io.mime_type
  #
  #   if image_type == "image/svg+xml" || io.metadata['filename'].end_with?('.svg')
  #     {original: io, large: io.download, medium: io.download, small: io.download}
  #   else
  #     large = resize_to_limit!(original, images_config[:large], images_config[:large]) {|cmd| cmd.auto_orient}
  #     medium = resize_to_limit(large, images_config[:medium], images_config[:medium])
  #     small = resize_to_limit(medium, images_config[:small], images_config[:small])
  #
  #     {original: io, large: large, medium: medium, small: small}
  #   end
  # end

  def generate_location(io, context)
    user_id = context[:record] ? context[:record].user_id : nil
    style = context[:version] != :original ? "resized" : "originals"
    name = "#{context.dig(:metadata, 'filename') ? context.dig(:metadata, 'filename').gsub(/\.\w+$/, '').parameterize : 'image'}-#{super(io, derivative: context[:version])}#{style}"

    [user_id, style, name].compact.join("/")
  end
end