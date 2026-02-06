module Sibu
  class Image < ApplicationRecord
    include ImageUploader::Attachment(:file)
    extend Sibu::UserConcern

    store :metadata, accessors: [:alt, :reference, :credits], coder: JSON

    validates_presence_of :file
  end
end
