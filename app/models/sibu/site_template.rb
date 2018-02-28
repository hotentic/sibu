module Sibu
  class SiteTemplate < ApplicationRecord
    store :default_sections, accessors: [:sections], coder: JSON
    store :default_pages, accessors: [:pages], coder: JSON
    store :default_templates, accessors: [:templates], coder: JSON

    def reference
      name.parameterize.gsub('-', '_')
    end

    def available_templates
      Dir.glob(File.join(Rails.root, "app/views/shared/#{path}/*.erb")).map {|f| f.split('/').last}
          .map {|f| f[1..-1].gsub('.html.erb', '')}.select {|f| f != 'site'}.map {|f| {"id" => "sibu_template_#{f}", "template" => f}}
    end
  end
end
