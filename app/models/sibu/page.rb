module Sibu
  class Page < ApplicationRecord
    include Sibu::SectionsConcern

    belongs_to :site, :class_name => 'Sibu::Site'

    store :metadata, accessors: [:title, :description], coder: JSON

    validates_presence_of :name, :site, :language, :template

    def save_and_init
      if valid?
        template_defaults = site.site_template.pages.select {|p| p[:template] == template}.first
        self.sections = template_defaults[:sections]  if template_defaults
      end
      save
    end
  end
end
