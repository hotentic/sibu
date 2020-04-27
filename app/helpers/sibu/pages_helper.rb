module Sibu
  module PagesHelper
    include Sibu::Engine.routes.url_helpers

    def link_path(page_id)
      p = @site.page_by_id(page_id)
      p ? (request.host == conf[:host] ? site_page_path(@site.id, p.id) : (conf[:deployment_path] ? "/#{conf[:deployment_path]}/#{p.path}" : "/#{p.path}")) : "#"
    end

    def sections_templates
      @site.site_template.available_sections
    end

    def site_images
      Sibu::Image.for_user(sibu_user).uniq
    end

    def available_links
      options_from_collection_for_select(@site.pages.order(:name), :id, :name, @element["value"])
    end

    def available_docs
      options_from_collection_for_select(Sibu::Document.for_user(sibu_user), :file_url, :file_name, @element["value"])
    end

    def link_type(val)
      if val.blank? || /^\d+$/.match(val.to_s)
        'internal'
      elsif Sibu::Document.for_user(sibu_user).map {|d| d.file_url}.include?(val)
        'document'
      elsif val.to_s.start_with?('http', '#', '/')
        'external'
      else
        'email'
      end
    end

    [:h1, :h2, :h3, :h4, :h5, :h6, :span].each do |t|
      define_method(t) do |elt, html_opts = {}, &block|
        defaults = {"id" => elt.is_a?(Hash) ? elt["id"] : elt, "text" => Sibu::DEFAULT_TEXT}
        content = defaults.merge(elt.is_a?(Hash) ? elt : (select_element(elt) || {}))
        html_opts.merge!({data: {id: elt_id(elt), type: "text"}}) if action_name != 'show'
        if block
          @sb_section = (@sb_section || []) + [elt_id(elt)]
          html_output = content_tag(t, capture(content, nested_elements(elt), &block), html_opts)
          @sb_section -= [elt_id(elt)]
          html_output
        else
          content_tag(t, raw(content["text"]).html_safe, html_opts)
        end
      end
    end

    [:div, :section, :article, :aside, :header, :footer, :nav, :main, :ul].each do |t|
      define_method(t) do |elt, html_opts = {}, &block|
        t_id = elt.is_a?(Hash) ? elt["id"] : elt
        @sb_section = (@sb_section || []) + [t_id]
        html_opts = {"id" => t_id}.merge(html_opts)
        html_opts.merge!(@sb_section.length == 1 ? {"data-sb-id" => t_id, "data-sb-entity" => @sb_entity == @site ? 'site' : 'page'} : {"data-id" => elt_id(elt), "data-type" =>  "group", "data-repeat" => false, "data-children" => false}) if action_name != 'show'
        html_output = content_tag(t, capture(current_elt(elt), nested_elements(t_id), &block), html_opts)
        @sb_section -= [t_id]
        html_output
      end
    end

    def sb
      self
    end

    def join_tokens(tokens, suffix)
      (tokens + [suffix]).select {|t| !t.blank?}.join("|")
    end

    def nested_elements(id)
      element_id = elt_id(id)
      element_id_tokens = (@sb_section + element_id.split("|")).uniq
      nested_elts = @sb_entity.elements(*element_id_tokens)
      nested_elts.blank? ? [{"id" => element_id.split("|").last, "data-id" => join_tokens(element_id_tokens[1..-1], "#{element_id}0")}] :
          nested_elts.map {|e| e.merge({"data-id" => join_tokens(element_id_tokens[1..-1], e['id'])})}
    end

    def select_element(id)
      @sb_entity.element(*@sb_section, id)
    end

    def elements(id = nil)
      items = id ? select_element(id)["elements"] : @sb_entity.find_or_init(*@sb_section)["elements"]
      items.blank? ? [{"id" => "el#{Time.current.to_i}"}] : items
    end

    def p(elt, opts = {})
      repeat = opts.delete(:repeat)
      defaults = {"id" => elt.is_a?(Hash) ? elt["id"] : elt, "text" => Sibu::DEFAULT_PARAGRAPH}
      content = defaults.merge(elt.is_a?(Hash) ? elt : (select_element(elt) || {}))
      opts.merge!({data: {id: elt_id(elt), repeat: repeat, type: "paragraph"}}) if action_name != 'show'
      content_tag(:div, content_tag(:p, raw(content["text"]).html_safe), opts)
    end

    def img(elt, opts = {})
      wrapper = opts.delete(:wrapper)
      repeat = opts.delete(:repeat)
      size = opts.delete(:size)
      defaults = {"id" => elt.is_a?(Hash) ? elt["id"] : elt, "src" => Sibu::DEFAULT_IMG}
      content = defaults.merge(elt.is_a?(Hash) ? elt : (select_element(elt) || {}))
      if action_name == 'show'
        content["src"] = ("/#{conf[:deployment_path]}" + content["src"]) if @online && conf[:deployment_path]
      else
        opts.merge!({data: {id: elt_id(elt), type: "media", repeat: repeat, size: size}})
      end
      wrapper ? content_tag(wrapper, content_tag(:img, nil, content.except("id")), opts)
          : content_tag(:img, nil, content.except("id").merge(opts.stringify_keys) {|k, old, new| k == 'class' ? [old, new].join(' ') : new})
    end

    def grp(elt, opts = {}, &block)
      wrapper = opts.delete(:wrapper) || :div
      repeat = opts.delete(:repeat)
      children = opts.delete(:children)
      defaults = {"id" => elt.is_a?(Hash) ? elt["id"] : elt}
      opts = defaults.merge(opts)
      opts.merge!({data: {id: elt_id(elt), type: "group", repeat: repeat, children: children}}) if action_name != 'show'
      content_tag(wrapper, capture(*elts(elt), &block), opts)
    end

    def empty_tag(elt, tag, type, opts = {})
      repeat = opts.delete(:repeat)
      defaults = {"id" => elt.is_a?(Hash) ? elt["id"] : elt}.merge!(default_content(type))
      opts = defaults.merge(opts)
      opts.merge!({data: {id: elt_id(elt), type: type, repeat: repeat}}) if action_name != 'show'
      content_tag(tag, nil, opts)
    end

    def form_label(elt, html_opts = {}, &block)
      defaults = {"id" => elt.is_a?(Hash) ? elt["id"] : elt, "text" => Sibu::DEFAULT_TEXT}
      content = defaults.merge(elt.is_a?(Hash) ? elt : (select_element(elt) || {}))
      html_opts.merge!({data: {id: elt_id(elt), type: "text"}}) if action_name != 'show'
      content_tag(:label, raw(content["text"]).html_safe, html_opts)
    end

    def widget(elt, widget_type, opts = {}, &block)
      content = elt.is_a?(Hash) ? elt : (select_element(elt) || {})
      opts.merge!({data: {id: elt_id(elt), type: "widget_#{widget_type.to_s.split('::').last.underscore}"}}) if action_name != 'show'
      content_tag(:div, capture(widget_type.new(content), &block), opts)
    end

    def embed(elt, opts = {})
      defaults = {"id" => elt.is_a?(Hash) ? elt["id"] : elt, "code" => '<p>Contenu HTML personnalisé (iframe, etc...)</p>'}
      content = defaults.merge(elt.is_a?(Hash) ? elt : (select_element(elt) || {}))
      opts.merge!({data: {id: elt_id(elt), type: "embed"}}) if action_name != 'show'
      content_tag(:div, content_tag(:p, raw(content["code"]).html_safe), opts)
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

    def render_page_section(s)
      @sb_section = [s['id']]
      @sb_entity = @page
      render partial: "shared/#{@site.section_template(s)}",
             locals: {sibu: self, sibu_section: s, sibu_attrs: sibu_attributes(s).html_safe}
    end

    def sibu_attributes(section)
      action_name != 'show' ? ('data-sb-id="' + section['id'] + '" data-sb-entity="page"') : ''
    end

    def section(id, tag, html_opts = {}, &block)
      @sb_section = [id]
      opts = action_name != 'show' ? html_opts.merge({"data-sb-id" => id, "data-sb-entity" => @sb_entity == @site ? 'site' : 'page'}) : html_opts
      content_tag(tag, capture(self, &block), opts)
    end

    def elts(id)
      items = []
      element_id = elt_id(id)
      elemnts = @sb_entity.elements(*(@sb_section + element_id.split("|")).uniq)
      if elemnts
        elemnts.each do |e|
          e["data-id"] = [element_id, e["id"]].join("|")
          items << e
        end
      end
      items.blank? ? [{"id" => element_id.split("|").last, "data-id" => [element_id, "#{element_id}0"].join("|")}] : items
    end

    def link(elt, html_opts = {}, &block)
      repeat = html_opts.delete(:repeat)
      children = html_opts.delete(:children)
      defaults = {"id" => elt_id(elt), "value" => "", "text" => Sibu::DEFAULT_TEXT}
      link_elt = current_elt(elt)
      content = defaults.merge(link_elt)
      val = content.delete("value") || ""
      text = content.delete("text")
      html_opts.merge!({data: {id: elt_id(elt), type: "link", repeat: repeat, children: children}}) if action_name != 'show'
      if val.to_s.start_with?('http')
        content["href"] = val
      elsif val.to_s.start_with?('#')
        content["href"] = val
        content.delete("target")
      elsif val.to_s.start_with?('/')
        content["href"] = val
      elsif val.to_s.include?('@')
        content["href"] = 'mailto:' + val
      else
        content["href"] = @links.keys.include?(val.to_s) ? (action_name == 'show' ? link_path(val) : site_page_edit_content_path(@site.id, val)) : '#'
      end
      if block_given?
        @sb_section = (@sb_section || []) + [elt_id(elt)]
        html_output = content_tag(:a, capture(link_elt, elts(elt), &block), content.merge(html_opts).except("elements"))
        @sb_section -= [elt_id(elt)]
        html_output
      else
        content_tag(:a, raw(text), content.merge(html_opts).except("elements"))
      end
    end

    def interactive_map(elt, html_opts = {})
      defaults = {"data-lat" => "45.68854", "data-lng" => "5.91587", "data-title" => Sibu::DEFAULT_TEXT}
      content = defaults.merge(elt.is_a?(Hash) ? elt : (select_element(elt) || {"id" => elt}))
      html_opts.merge!({data: {id: elt_id(elt), type: "map"}}) if action_name != 'show'
      content_tag(:div, nil, content.merge(html_opts))
    end

    def elt_id(elt)
      elt.is_a?(Hash) ? (elt["data-id"] || elt["id"]) : elt
    end

    def current_elt(elt)
      (elt.is_a?(Hash) ? elt : (select_element(elt) || {})).except('elements')
    end

    def default_content(type)
      case type
      when "text"
        {"text" => Sibu::DEFAULT_TEXT}
      when "link"
        {"value" => "", "text" => Sibu::DEFAULT_TEXT}
      when "paragraph"
        {"text" => Sibu::DEFAULT_PARAGRAPH}
      when "media"
        {"src" => Sibu::DEFAULT_IMG}
      when "embed"
        {"code" => '<p>Contenu HTML personnalisé (iframe, etc...)</p>'}
      end
    end
  end
end
