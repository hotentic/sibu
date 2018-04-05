module Sibu
  class Document < ApplicationRecord
    include DocumentUploader::Attachment.new(:file, cache: :documents_cache, store: :documents_store)
    extend Sibu::UserConcern

    validates_presence_of :file_data

    store :file_data, accessors: [:metadata], coder: JSON

    def file_name
      metadata[:filename]
    end
  end
end
