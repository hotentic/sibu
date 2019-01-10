module Sibu
  class Page < ApplicationRecord
    include Sibu::SectionsConcern

    belongs_to :site, :class_name => 'Sibu::Site'

    store :custom_data, accessors: [:header_code, :footer_code], coder: JSON
    store :metadata, accessors: [:title, :description, :keywords], coder: JSON

    before_save :update_path
    validates_presence_of :name, :site

    def self.lookup(domain_name, page_query)
      page_path = (page_query || '').strip.split('?')[0]
      if page_path.blank?
        joins(:site).where("sibu_sites.domain = ? AND COALESCE(sibu_pages.path, '') = ''", domain_name).first
      else
        paths = page_path.split('/').inject([]) {|p, s| p << (p.length == 0 ? s : "#{p[-1]}/#{s}")}
        joins(:site).where("sibu_sites.domain = ? AND COALESCE(sibu_pages.path, '') IN (?)", domain_name, paths)
            .order(path: :desc)
            .first
      end
    end

    def save_and_init
      if valid?
        template_defaults = site.site_template.pages.first
        self.sections = template_defaults[:sections]  if template_defaults
      end
      save
    end

    # Todo : fix me (is_home flag ?)
    def update_path
      prefix = site.version == Sibu::Site::DEFAULT_VERSION ? '' : "#{site.version}/"
      self.path = "#{prefix}#{name != 'Accueil' ? name.parameterize : ''}" if self.path.blank?
    end

    def site_template
      site.site_template
    end

    def deep_copy
      new_page = deep_dup
      new_page.name = name + ' - copie'
      new_page
    end

    def update_templates(sections_templates)
      sections.each do |s|
        s["template"] = sections_templates[s["id"]]
      end
      save
    end

    def reorder_sections(*ordered_ids)
      if ordered_ids.length == sections.length
        self.sections = ordered_ids.map {|section_id| sections.find {|sec| sec["id"] == section_id}}
        save
      end
    end
  end
end
