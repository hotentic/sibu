module Sibu
  class Site < ApplicationRecord
    include Sibu::SectionsConcern

    store :custom_data, accessors: [:primary_font, :secondary_font, :primary_color, :secondary_color], coder: JSON

    belongs_to :site_template, :class_name => 'Sibu::SiteTemplate'
    has_many :pages, :class_name => 'Sibu::Page', dependent: :destroy
    has_many :images, :class_name => 'Sibu::Image', dependent: :destroy

    validates_presence_of :name, :site_template

    def section_template(section)
      "#{site_template.path}/#{section["template"]}"
    end

    def not_found
      "shared/#{site_template.path}/not_found"
    end

    def page(path)
      pages.where(path: path).first
    end

    def page_by_id(page_id)
      pages.where(id: page_id).first
    end

    def save_and_init
      if valid?
        self.sections = site_template.sections
        site_template.pages.each do |p|
          self.pages << Sibu::Page.new(p)
        end
      end
      save
    end

    def pages_path_by_id
      Hash[pages.collect {|p| [p.id.to_s, p.path]}]
    end

    def init_pages(source)
      site_data = Rails.application.config.sibu[:site_data][source]
      site_data.pages.each do |p|
        self.pages << Sibu::Page.new(p)
      end
      save!
    end

    def init_sections(source)
      site_data = Rails.application.config.sibu[:site_data][source]
      self.sections = site_data.sections(self)
      save!
    end
  end
end
