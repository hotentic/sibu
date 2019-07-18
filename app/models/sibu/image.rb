module Sibu
  class Image < ApplicationRecord
    include ImageUploader::Attachment.new(:file)
    extend Sibu::UserConcern

    store :metadata, accessors: [:alt, :reference, :credits], coder: JSON

    validates_presence_of :file_data
  end
end
