module Sibu
  class Site < ApplicationRecord
    include Sibu::SectionsConcern

    belongs_to :site_template, :class_name => 'Sibu::SiteTemplate'
    has_many :pages, :class_name => 'Sibu::Page', dependent: :destroy

    validates_presence_of :name, :site_template

    def page_template(page)
      "#{site_template.path}/#{page.template}"
    end

    def not_found
      "#{site_template.path}/not_found"
    end

    def page(path)
      pages.where(path: path).first
    end

    def page_by_id(page_id)
      pages.where(id: page_id).first
    end

    def save_and_init(source)
      ActiveRecord::Base.transaction do
        save!
        init_pages(source)
        init_sections(source)
      end
    end

    def internal_links
      Hash[pages.collect {|p| [p.id, p.path]}]
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
