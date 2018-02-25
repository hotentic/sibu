module Sibu
  class SiteTemplate < ApplicationRecord
    store :default_sections, accessors: [:sections], coder: JSON
    store :default_pages, accessors: [:pages], coder: JSON

    def reference
      name.parameterize.gsub('-', '_')
    end
  end
end
