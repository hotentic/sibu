module Sibu
  module PagesHelper
    include Sibu::Engine.routes.url_helpers

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

    [:h1, :h2, :h3, :h4, :h5, :h6, :p, :span, :div].each do |t|
      define_method(t) do |id_or_elt, html_opts = {}|
        content = id_or_elt.is_a?(Hash) ? (id_or_elt || {"text" => "Texte à modifier"}) : (select(id_or_elt) || {"text" => "Texte à modifier"})
        html_opts.merge!({class: "sb-#{t} #{html_opts[:class]}", data: {id:  id_or_elt.is_a?(Hash) ? id_or_elt["id"] : id_or_elt}}) if action_name != 'show'
        content_tag(t, raw(content["text"]).html_safe, html_opts)
      end
    end

    def sb
      self
    end

    def select(id)
      @sb_entity.section(@sb_section).select {|elt| elt["id"] == id}.first
    end

    def site_section(id, &block)
      @sb_entity = @site
      @sb_section = id
      capture(self, &block)
    end

    def section(id, &block)
      @sb_entity = @page
      @sb_section = id
      capture(self, &block)
    end

    def each
      # Todo : init array when empty
      @sb_entity.section(@sb_section).each do |elt|
        yield(elt.except("elements"), elt["elements"])
      end
    end

    def each_elements
      @sb_entity.section(@sb_section).each do |elt|
        yield(*elt["elements"])
      end
    end

    def img(id_or_elt, html_opts = {})
      content = id_or_elt.is_a?(Hash) ? (id_or_elt || {"src" => "/default.jpg"}) : (select(id_or_elt) || {"src" => "/default.jpg"})
      opts = action_name == 'show' ? html_opts.merge({class: "sb-img #{html_opts[:class]}", data: {id: id_or_elt.is_a?(Hash) ? id_or_elt["id"] : id_or_elt}}) : html_opts
      content_tag(:img, nil, content.except("id").merge(opts))
    end

    def link(id_or_elt, html_opts = {}, &block)
      content = id_or_elt.is_a?(Hash) ? (id_or_elt || {"value" => "", "text" => "Nouveau lien"}) : (select(id_or_elt) || {"value" => "", "text" => "Nouveau lien"})
      val = content["value"] || ""
      if val.to_s.include?('http')
        href = val
      else
        href = @links.keys.include?(val) ? (action_name == 'show' ? link_path(val) : site_page_edit_content_path(@site.id, val)) : '#'
      end
      if block_given?
        content_tag(:a, {href: href}.merge(html_opts), &block)
      else
        content_tag(:a, content["text"], {href: href}.merge(html_opts))
      end
    end

    def form_label(id_or_elt, html_opts = {}, &block)
      content = id_or_elt.is_a?(Hash) ? (id_or_elt || {"text" => "Texte à modifier"}) : (select(id_or_elt) || {"text" => "Texte à modifier"})
      html_opts.merge!({class: "sb-label #{html_opts[:class]}", data: {id:  id_or_elt.is_a?(Hash) ? id_or_elt["id"] : id_or_elt}}) if action_name != 'show'
      content_tag(:label, raw(content["text"]).html_safe, html_opts)
    end
  end
end
