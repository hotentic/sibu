module Sibu
  class Image < ApplicationRecord
    include ImageUploader::Attachment.new(:file)
    extend Sibu::UserConcern

    store :metadata, accessors: [:alt, :reference, :credits], coder: JSON

    validates_presence_of :file_data

    def self.empty
      empty_img = where("metadata ILIKE '%default_empty_image%'").first
      if empty_img.nil?
        empty_img = new(reference: 'default_empty_image', file: File.new('app/assets/images/empty.png'))
        empty_img.save
      end
      empty_img
    end
  end
end

# ['beds-green.svg', 'camp-white.svg', 'doc-green.svg', 'doc-white.svg', 'earth-white.svg', 'family-sec_blue.svg',
# 'family-white.svg', 'flag.svg', 'hands-green.svg', 'home-green.svg', 'house-white.svg', 'marker.svg', 'men-green.svg',
# 'money-blue.svg', 'money-green.svg', 'quotes.svg', 'tel-green.svg', 'tel-white.svg', 'tv-green.svg']