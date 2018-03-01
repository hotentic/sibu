module Sibu
  class Site < ApplicationRecord
    include StyleUploader::Attachment.new(:style, cache: :styles_cache, store: :styles_store)
    include Sibu::SectionsConcern

    store :custom_data, accessors: [:primary_font, :secondary_font, :primary_color, :secondary_color], coder: JSON
    store :metadata, accessors: [:analytics_id], coder: JSON

    belongs_to :site_template, :class_name => 'Sibu::SiteTemplate'
    has_many :pages, :class_name => 'Sibu::Page', dependent: :destroy
    has_many :images, :class_name => 'Sibu::Image', dependent: :destroy

    validates_presence_of :name, :site_template

    def style_url
      style ? style.url : site_template.path
    end

    def main_color
      primary_color.blank? ? site_template.primary_color : primary_color
    end

    def alt_color
      secondary_color.blank? ? site_template.secondary_color : secondary_color
    end

    def main_font
      primary_font.blank? ? site_template.primary_font : primary_font
    end

    def alt_font
      secondary_font.blank? ? site_template.secondary_font : secondary_font
    end

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
