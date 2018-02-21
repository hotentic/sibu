module Sibu
  module PagesHelper
    include Sibu::Engine.routes.url_helpers

    def link_path(page_id)
      p = @site.page_by_id(page_id)
      p ? (@site.domain.blank? ? site_page_path(@site.id, p.id) : "/#{p.path}") : "#"
    end

    def page_templates
      [['Accueil', 'home'], ['Offre', 'offer'], ['Galerie', 'gallery'], ['Destination', 'destination'], ['Mentions légales', 'text']]
    end

    def page_languages
      [['Français', 'fr'], ['Anglais', 'en']]
    end

    def site_images
      @site.images + Sibu::Image.shared
    end

    def available_links
      options_from_collection_for_select(@site.pages, :id, :name, @element["value"])
    end

    def is_internal(val)
      val.blank? || val == '#' || /^\d{1,3}$/.match(val.to_s)
    end

    [:h1, :h2, :h3, :h4, :h5, :h6, :span].each do |t|
      define_method(t) do |elt, html_opts = {}|
        defaults = {"id" => elt.is_a?(Hash) ? elt["id"] : elt, "text" => "Texte à modifier"}
        content = defaults.merge(elt.is_a?(Hash) ? elt : (select_element(elt) || {}))
        html_opts.merge!({data: {id: elt_id(elt), type: "text"}}) if action_name != 'show'
        content_tag(t, raw(content["text"]).html_safe, html_opts)
      end
    end

    def p(elt, html_opts = {})
      defaults = {"id" => elt.is_a?(Hash) ? elt["id"] : elt, "text" => "Texte à modifier"}
      content = defaults.merge(elt.is_a?(Hash) ? elt : (select_element(elt) || {}))
      html_opts.merge!({data: {id: elt_id(elt), type: "paragraph"}}) if action_name != 'show'
      content_tag(:div, content_tag(:p, raw(content["text"]).html_safe), html_opts)
    end

    def sb
      self
    end

    def select_element(id)
      @sb_entity.section(*@sb_section).select {|elt| elt["id"] == id}.first
    end

    def elements(id = nil)
      id ? select_element(id)["elements"] : @sb_entity.section(*@sb_section)
    end

    def img(elt, opts = {})
      wrapper = opts.delete(:wrapper)
      repeat = opts.delete(:repeat)
      size = opts.delete(:size)
      defaults = {"id" => elt.is_a?(Hash) ? elt["id"] : elt, "src" => "/default.jpg"}
      content = defaults.merge(elt.is_a?(Hash) ? elt : (select_element(elt) || {}))
      opts.merge!({data: {id: elt_id(elt), type: "media", repeat: repeat, size: size}}) if action_name != 'show'
      wrapper ? content_tag(wrapper, content_tag(:img, nil, content.except("id")), opts) : content_tag(:img, nil, content.except("id").merge(opts))
    end

    # Note : see ActionView::OutputBuffer
    def sb_page
      @sb_entity = @page
      self
    end
    alias page sb_page

    def sb_site
      @sb_entity = @site
      self
    end
    alias site sb_site

    def section(id, tag, html_opts = {}, &block)
      @sb_section = [id]
      rpt = html_opts.delete(:repeat)
      opts = action_name != 'show' ? html_opts.merge({"data-sb-id" => id, "data-sb-repeat" => rpt, "data-sb-entity" => @sb_entity == @site ? 'site' : 'page'}) : html_opts
      content_tag(tag, capture(self, &block), opts)
    end

    def sections(id, tag, html_opts = {}, &block)
      (@sb_entity.section(id).map.with_index do |elt, i|
        @sb_section = [id, elt["id"]]
        opts = action_name != 'show' ? html_opts.merge({"data-sb-id" => @sb_section.join('|'), "data-sb-repeat" => true, "data-sb-entity" => @sb_entity == @site ? 'site' : 'page'}) : html_opts
        content_tag(tag, capture(self, i, &block), opts)
      end).join('').html_safe
    end

    def elt(id)
      select_element(id)
    end

    # Note : could work well - set the ids hierarchy in elements retrieved from the db
    def elts(id)
      items = []
      @sb_entity.section(*@sb_section, id).each do |item|
        item["id"] = [id, item["id"]].join("|")
        items << item
      end
      items
    end

    def link(elt, html_opts = {}, &block)
      repeat = html_opts.delete(:repeat)
      defaults = {"id" => elt_id(elt), "value" => "", "text" => "Nouveau lien"}
      content = defaults.merge(elt.is_a?(Hash) ? elt : (select_element(elt) || {}))
      val = content.delete("value") || ""
      text = content.delete("text");
      html_opts.merge!({data: {id: elt_id(elt), type: "link", repeat: repeat}}) if action_name != 'show'
      if val.to_s.include?('http')
        content["href"] = val
      else
        content["href"] = @links.keys.include?(val.to_s) ? (action_name == 'show' ? link_path(val) : site_page_edit_content_path(@site.id, val)) : '#'
      end
      if block_given?
        content_tag(:a, content.merge(html_opts), &block)
      else
        content_tag(:a, text, content.merge(html_opts))
      end
    end

    def interactive_map(elt, html_opts = {}, &block)
      defaults = {"data-lat" => "45.68854", "data-lng" => "5.91587", "data-title" => "Titre marqueur"}
      content = elt.is_a?(Hash) ? defaults.merge(elt) : (select_element(elt) || {"id" => elt}).merge(defaults)
      html_opts.merge!({data: {id: elt_id(elt), type: "map"}}) if action_name != 'show'
      content_tag(:div, nil, content.merge(html_opts))
    end

    def elt_id(elt)
      elt.is_a?(Hash) ? elt["id"] : elt
    end
  end
end
