module ActionView
  module Helpers
    module TagHelper
      # Todo : handle default values => sections can be totally empty or have at least 1 elt
      # If "emptyable", how do we add the 1st elt ? If not, how do we provide a default value ?
      class SectionHelper
        include ActionView::Helpers::TagHelper

        attr_reader :entity_type

        [:h1, :h2, :h3, :h4, :h5, :h6, :p, :span, :div].each do |t|
          define_method(t) do |id, html_opts = {}|
            html_opts.merge!({class: "sb-#{t} #{html_opts[:class]}", data: {id: id}}) if @edit
            content_tag(t, (@elements.dig(id, "text") || "Texte à modifier"), html_opts)
          end
        end

        def initialize(*ids, entity, edit_mode)
          @id = ids.join('|')
          @entity_type = entity.is_a?(Sibu::Page) ? 'page' : 'site'
          elts = entity.section(*ids)
          @elements = elts.blank? ? {"default" => {}} : Hash[elts.map {|e| [e["id"], e.except("id")]}]
          @edit = edit_mode
        end

        # Note : add sb-img back - see how the extra div could be removed
        def img(id, html_opts = {})
          content = id == "default" ? {"src" => "/default.jpg"} : (@elements[id] || {"src" => "/default.jpg"})
          if @edit
            content_tag(:div, content_tag(:img, nil, content.merge(html_opts)), {class: "rel h100 #{html_opts[:class]}", data: {id: id}})
          else
            content_tag(:img, nil, content.merge(html_opts))
          end
        end

        def lnk(id)
          @elements[id] || {"value" => "", "text" => "Nouveau lien"}
        end

        # def subsection(id, &block)
        #   section
          # s = SectionHelper.new(id, @entity_type, @elements[id], @edit)
          # if !@edit
          #   capture(s, &block)
          # else
          #   "<sb-edit data-id='#{id}' data-entity='#{@entity_type}'>#{capture(s, &block)}</sb-edit>".html_safe
          # end
        # end

        def elements(&block)
          @elements.each_pair(&block)
        end
      end

      def section(id, entity = @page, &block)
        s = SectionHelper.new(id, entity, action_name != 'show')
        if action_name == 'show'
          capture(s, &block)
        else
          "<sb-edit data-id='#{id}' data-entity='#{s.entity_type}'>#{capture(s, &block)}</sb-edit>".html_safe
        end
      end

      def subsection(id, sub_id, entity = @page, &block)
        entity_type = entity.is_a?(Sibu::Page) ? 'page' : 'site'
        s = SectionHelper.new(id, sub_id, entity, action_name != 'show')
        # if action_name == 'show'
          capture(s, &block)
        # else
        #   "<sb-edit data-id='#{id}' data-entity='#{s.entity_type}'>#{capture(s, &block)}</sb-edit>".html_safe
        # end
      end
    end
  end
end
