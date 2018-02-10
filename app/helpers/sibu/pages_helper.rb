module Sibu
  module PagesHelper
    include Sibu::Engine.routes.url_helpers
    include TrixEditorHelper


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
      define_method(t) do |elt, html_opts = {}|
        content = elt.is_a?(Hash) ? (elt || {"text" => "Texte à modifier"}) : (select(elt) || {"text" => "Texte à modifier"})
        html_opts.merge!({class: "sb-#{t} #{html_opts[:class]}", data: {id:  elt.is_a?(Hash) ? elt["id"] : elt}}) if action_name != 'show'
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
      if block_given?
        "<sb-edit data-id='#{id}' data-entity='site'>#{capture(self, &block)}</sb-edit>".html_safe
      else
        self
      end
    end

    def section(id, &block)
      @sb_entity = @page
      @sb_section = id
      "<sb-edit data-id='#{id}' data-entity='page'>#{capture(self, &block)}</sb-edit>".html_safe
    end

    def site_sections(id)
      @site.section(id).map {|s| s["id"]}
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

    def img(elt, html_opts = {})
      content = elt.is_a?(Hash) ? ((elt && !elt["src"].blank?) ? elt : {"src" => "/default.jpg"}) : ((select(elt) && !select(elt)["src"].blank?) ? select(elt) : {"src" => "/default.jpg"})
      html_opts.merge!({class: "sb-img #{html_opts[:class]}", data: {id: elt.is_a?(Hash) ? elt["id"] : elt}}) if action_name != 'show'
      content_tag(:img, nil, content.except("id").merge(html_opts))
    end

    def link(elt, html_opts = {}, &block)
      content = elt.is_a?(Hash) ? (elt || {"value" => "", "text" => "Nouveau lien"}) : (select(elt) || {"value" => "", "text" => "Nouveau lien"})
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

    def form_label(elt, html_opts = {}, &block)
      content = elt.is_a?(Hash) ? (elt || {"text" => "Texte à modifier"}) : (select(elt) || {"text" => "Texte à modifier"})
      html_opts.merge!({class: "sb-label #{html_opts[:class]}", data: {id:  elt.is_a?(Hash) ? elt["id"] : elt}}) if action_name != 'show'
      content_tag(:label, raw(content["text"]).html_safe, html_opts)
    end
  end
end
