module Sibu
  module PagesHelper

    # Todo : define in initializer as an extension of TagHelper module - only add 'sb' class when editing
    # class Section
    #   include ActionView::Helpers::TagHelper
    #
    #   attr_reader :id, :elements
    #
    #   [:h1, :h2, :h3, :h4, :h5, :h6, :p, :span, :div].each do |t|
    #     define_method(t) do |id, cl = ''|
    #       content_tag(t, (elements.dig(id, "value") || "Texte à modifier"), class: cl + ' sb')
    #     end
    #   end
    #
    #   def initialize(hsh)
    #     @id = hsh["id"]
    #     @elements = Hash[hsh["elements"].map {|e| [e["id"], e]}]
    #   end
    #
    #   def img(id)
    #     elements.dig(id, "value") || "/default.jpg"
    #   end
    #
    #   def lnk(id)
    #     elements[id] || {"value" => "#", "label" => "Nouveau lien"}
    #   end
    #
    #   def values(default_val)
    #     elements.any? ? elements.values.map {|v| v["value"]} : [default_val]
    #   end
    #
    #   def images
    #     values("/default.jpg")
    #   end
    # end

    # def section(id, entity = @page, &block)
    #   s = Section.new(entity.section(id))
    #   if action_name == 'show'
    #     capture(s, &block)
    #   else
    #     "<sb-edit>#{capture(s, &block)}</sb-edit>".html_safe
    #   end
    # end

    # def txt(section, id, tag)
    #   "<#{tag}>#{section.elements.dig(id, "value") || "Texte à modifier"}</#{tag}>".html_safe
    # end
    #
    # def img(id)
    #   elements.dig(id, "value") || "/default.jpg"
    # end
    #
    # def lnk(id)
    #   elements[id] || {"value" => "#", "label" => "Nouveau lien"}
    # end

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
