module Sibu
  module SitesHelper
    def primary_colors
      ([@site.site_template.primary_color] + Rails.application.config.sibu[:primary_colors]).uniq
    end

    def secondary_colors
      ([@site.site_template.secondary_color] + Rails.application.config.sibu[:secondary_colors]).uniq
    end

    def primary_fonts
      ([@site.site_template.primary_font] + Rails.application.config.sibu[:primary_fonts]).uniq.map.each_with_index {|f, i| [i == 0 ? (f + ' (par défaut)') : f, f]}
    end

    def secondary_fonts
      ([@site.site_template.secondary_font] + Rails.application.config.sibu[:secondary_fonts]).uniq.map.each_with_index {|f, i| [i == 0 ? (f + ' (par défaut)') : f, f]}
    end

    def site_versions
      Rails.application.config.sibu[:versions] || [['Français', 'fr']]
    end
  end
end
