module Sibu
  class Image < ApplicationRecord
    include ImageUploader::Attachment.new(:file)

    belongs_to :site, :class_name => 'Sibu::Site'
  end
end
