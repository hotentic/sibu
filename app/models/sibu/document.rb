module Sibu
  class Document < ApplicationRecord
    include DocumentUploader::Attachment.new(:file, cache: :documents_cache, store: :documents_store)
    extend Sibu::UserConcern

    validates_presence_of :file_data

    def metadata
      JSON.parse(file_data, symbolize_names: true)[:metadata]
    end

    def file_name
      metadata[:filename]
    end
  end
end
