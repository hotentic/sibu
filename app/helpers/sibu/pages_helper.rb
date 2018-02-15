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
        defaults = {"id" => elt.is_a?(Hash) ? elt["id"] : elt, "text" => "Texte à modifier"}
        content = defaults.merge(elt.is_a?(Hash) ? elt : (select_element(elt) || {}))
        html_opts.merge!({class: "sb-#{t} #{html_opts[:class]}", data: {id: elt_id(elt)}}) if action_name != 'show'
        content_tag(t, raw(content["text"]).html_safe, html_opts)
      end
    end

    def sb
      self
    end

    def select_element(id)
      @sb_entity.section(*@sb_section).select {|elt| elt["id"] == id}.first
    end

    def site_section(id, sub_id = nil, &block)
      @sb_entity = @site
      @sb_section = sub_id ? [id, sub_id] : [id]
      if block_given?
        if action_name != 'show'
          "<sb-edit data-id='#{@sb_section.join('|')}' data-entity='site'>#{capture(self, &block)}</sb-edit>".html_safe
        else
          capture(self, &block)
        end
      else
        self
      end
    end

    def section(id, sub_id = nil, &block)
      @sb_entity = @page
      @sb_section = sub_id ? [id, sub_id] : [id]
      if action_name != 'show'
        "<sb-edit data-id='#{@sb_section.join('|')}' data-entity='page' data-duplicate='#{!sub_id.nil?}'>#{capture(self, &block)}</sb-edit>".html_safe
      else
        capture(self, &block)
      end
    end

    # def site_sections(id, &block)
      # @site.section(id).map {|s| s["id"]}.each do |s|
      #   site_section(id, sub_id, &block)
      # end
    #   out = ''
    #   @sb_entity = @site
    #   @site.section(id).map do |s|
    #     @sb_section = [id, s["id"]]
    #     out += "<sb-edit data-id='#{@sb_section.join('|')}' data-entity='site' data-duplicate='true'>#{capture(self, &block)}</sb-edit>".html_safe
    #   end
    #   out.html_safe
    # end

    def site_sections(id)
      @site.section(id).map {|s| s["id"]}
    end

    def sections(id)
      @page.section(id).map {|s| s["id"]}
    end

    def elements(id = nil)
      id ? select_element(id)["elements"] : @sb_entity.section(*@sb_section)
    end

    def each
      # Todo : init array when empty
      @sb_entity.section(*@sb_section).each do |elt|
        yield(elt.except("elements"), elt["elements"])
      end
    end

    def each_elements
      @sb_entity.section(*@sb_section).each do |elt|
        yield(*elt["elements"])
      end
    end

    def img(elt, opts = {})
      wrapper = opts.delete(:wrapper)
      defaults = {"id" => elt.is_a?(Hash) ? elt["id"] : elt, "src" => "/default.jpg"}
      content = defaults.merge(elt.is_a?(Hash) ? elt : (select_element(elt) || {}))
      opts.merge!({class: "sb-img #{opts[:class]}", data: {id: elt_id(elt)}}) if action_name != 'show'
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

    # def repeat(id, tag, html_opts = {}, &block)
    #   @sb_section = [id]
    #   opts = action_name != 'show' ? html_opts.merge({"data-sb-id" => id, "data-sb-entity" => @sb_entity == @site ? 'site' : 'page'}) : html_opts
    #   ((action_name != 'show' ? "<sb-edit data-id='#{@sb_section}' data-entity='#{@sb_entity == @site ? 'site' : 'page'}'>" : '') +
    #       @sb_entity.section(@sb_section).map {|elt| capture(elt, &block)}.join('') +
    #     (action_name != 'show' ? "</sb-edit>" : '')).html_safe
    # end

    # def secsion(id)
    #   @sb_section = id
    #   if block_given?
    #     if current_action != 'show'
    #       "<sb-edit data-id='#{@sb_section}' data-entity='#{@sb_entity == @site ? 'site' : 'page'}'>#{capture(self, &block)}</sb-edit>".html_safe
    #     else
    #       capture(self, &block)
    #     end
    #   else
    #     self
    #   end
    # end
    #
    # def secsions(id)
    #
    # end

    def secsion(id, tag, html_opts = {}, &block)
      @sb_section = [id]
      rpt = html_opts.delete(:repeat)
      opts = action_name != 'show' ? html_opts.merge({"data-sb-id" => id, "data-sb-repeat" => rpt, "data-sb-entity" => @sb_entity == @site ? 'site' : 'page'}) : html_opts
      content_tag(tag, capture(self, &block), opts)
    end

    def secsions(id, tag, html_opts = {}, &block)
      (@sb_entity.section(id).map.with_index do |elt, i|
        @sb_section = [id, elt["id"]]
        opts = action_name != 'show' ? html_opts.merge({"data-sb-id" => @sb_section.join('|'), "data-sb-repeat" => true, "data-sb-entity" => @sb_entity == @site ? 'site' : 'page'}) : html_opts
        content_tag(tag, capture(self, i, &block), opts)
      end).join('').html_safe
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

    # def bg_img(elt, html_opts = {})
    #   defaults = {"id" => elt.is_a?(Hash) ? elt["id"] : elt, "src" => "/default.jpg"}
    #   content = defaults.merge(elt.is_a?(Hash) ? elt : (select_element(elt) || {}))
    #   html_opts.merge!({class: "sb-img #{html_opts[:class]}", data: {id: elt.is_a?(Hash) ? elt["id"] : elt}}) if action_name != 'show'
    #   content_tag(:div, content_tag(:img, nil, content.except("id")), html_opts)
    # end

    def link(elt, html_opts = {}, &block)
      defaults = {"id" => elt.is_a?(Hash) ? elt["id"] : elt, "value" => "", "text" => "Nouveau lien"}
      content = defaults.merge(elt.is_a?(Hash) ? elt : (select_element(elt) || {}))
      html_opts.merge!({class: "sb-link #{html_opts[:class]}", data: {id: elt_id(elt)}}) if action_name != 'show'
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
      defaults = {"id" => elt.is_a?(Hash) ? elt["id"] : elt, "text" => "Texte à modifier"}
      content = defaults.merge(elt.is_a?(Hash) ? elt : (select_element(elt) || {}))
      html_opts.merge!({class: "sb-label #{html_opts[:class]}", data: {id: elt_id(elt)}}) if action_name != 'show'
      content_tag(:label, raw(content["text"]).html_safe, html_opts)
    end

    def interactive_map(elt, html_opts = {}, &block)
      defaults = {"data-lat" => "45.68854", "data-lng" => "5.91587", "data-title" => "Titre marqueur"}
      content = elt.is_a?(Hash) ? defaults.merge(elt) : (select_element(elt) || {"id" => elt}).merge(defaults)
      html_opts.merge!({class: "sb-map #{html_opts[:class]}", data: {id: elt_id(elt)}}) if action_name != 'show'
      content_tag(:div, nil, content.merge(html_opts))
    end

    def elt_id(elt)
      elt.is_a?(Hash) ? elt["id"] : elt
    end
  end
end
