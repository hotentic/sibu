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

    def init_data(source)
      site_data = Rails.application.config.sibu_site_data[source]
      self.sections = site_data.sections
      site_data.pages.each do |p|
        self.pages << Sibu::Page.new(p)
      end
    end
  end
end
