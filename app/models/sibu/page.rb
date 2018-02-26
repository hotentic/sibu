module Sibu
  class Page < ApplicationRecord
    include Sibu::SectionsConcern

    belongs_to :site, :class_name => 'Sibu::Site'

    store :metadata, accessors: [:title, :description, :keywords], coder: JSON

    before_save :update_path
    validates_presence_of :name, :site, :language

    def save_and_init
      if valid?
        template_defaults = site.site_template.pages.first
        self.sections = template_defaults[:sections]  if template_defaults
      end
      save
    end

    # Todo : fix me (is_home flag ?)
    def update_path
      self.path = name.parameterize if self.path.blank? && name != 'Accueil'
    end
  end
end
