module Sibu
  class SiteTemplate < ApplicationRecord
    store :default_sections, accessors: [:sections], coder: JSON
    store :default_pages, accessors: [:pages], coder: JSON
    store :default_templates, accessors: [:templates], coder: JSON
    store :default_styles, accessors: [:primary_font, :secondary_font, :primary_color, :secondary_color], coder: JSON

    def reference
      ref || name.parameterize.gsub('-', '_')
    end

    def available_sections(path_prefix = 'app/views/shared')
      sections_list = []
      Dir.glob(File.join(Rails.root, "#{path_prefix}/#{path}/*/")).each do |dir|
        cat = dir.split('/').last
        sections_list += Dir.glob(dir + "*.erb").map {|f| f.split('/').last}.
            map {|f| f[1..-1].gsub('.html.erb', '')}.map {|f| {"id" => "sibu_template_#{f}", "category" => cat, "template" => f}}
      end
      if Rails.application.config.sibu[:sections_ordering]
        sections_list = Rails.application.config.sibu[:sections_ordering].call(sections_list)
      end
      sections_list
    end
  end
end
