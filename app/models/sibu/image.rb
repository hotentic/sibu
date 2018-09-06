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
