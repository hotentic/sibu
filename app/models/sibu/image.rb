module Sibu
  class Image < ApplicationRecord
    include ImageUploader::Attachment.new(:file)
  end
end
