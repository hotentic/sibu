module Sibu
  class Page < ApplicationRecord
    include Sibu::SectionsConcern

    belongs_to :site, :class_name => 'Sibu::Site'

    store :metadata, accessors: [:title, :description, :keywords], coder: JSON

    before_save :init_path
    validates_presence_of :name, :site, :language, :template

    def save_and_init
      if valid?
        template_defaults = site.site_template.pages.select {|p| p[:template] == template}.first
        self.sections = template_defaults[:sections]  if template_defaults
      end
      save
    end

    def init_path
      self.path = template if self.path.blank? && template != 'home'
    end
  end
end
