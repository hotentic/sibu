module Sibu
  class Image < ApplicationRecord
    include ImageUploader::Attachment.new(:file)

    belongs_to :site, :class_name => 'Sibu::Site', optional: true

    store :metadata, accessors: [:alt], coder: JSON

    validates_presence_of :file_data

    def self.shared
      where(site_id: nil)
    end
  end
end
