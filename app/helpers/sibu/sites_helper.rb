module Sibu
  module SitesHelper
    def primary_colors
      Rails.application.config.sibu[:primary_colors]
    end

    def secondary_colors
      Rails.application.config.sibu[:secondary_colors]
    end

    def primary_fonts
      [''] + Rails.application.config.sibu[:primary_fonts]
    end

    def secondary_fonts
      [''] + Rails.application.config.sibu[:secondary_fonts]
    end
  end
end
