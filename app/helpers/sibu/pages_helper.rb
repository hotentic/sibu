module Sibu
  module PagesHelper
    def link_path(page_id)
      p = @site.page_by_id(page_id)
      p ? (@site.domain.blank? ? site_page_path(@site.id, p.id) : "/#{p.path}") : "#"
    end

    def page_templates
      [['Accueil', 'home'], ['Offre', 'offer'], ['Galerie', 'gallery'], ['Destination', 'destination']]
    end

    def page_languages
      [['Français', 'fr'], ['Anglais', 'en']]
    end
  end
end
