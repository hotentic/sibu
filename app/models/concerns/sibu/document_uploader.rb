class Sibu::DocumentUploader < Shrine
  plugin :validation_helpers

  Attacher.validate do
    validate_max_size (Rails.application.config.sibu[:max_doc_size] || 10)*1024*1024, message: "est trop volumineux (#{Rails.application.config.sibu[:max_doc_size] || 10}Mo maximum)"
    # validate_mime_type_inclusion %w[application/pdf]
  end
end
