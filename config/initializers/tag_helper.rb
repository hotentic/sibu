module ActionView
  module Helpers
    module TagHelper
      class SectionHelper
        include ActionView::Helpers::TagHelper

        attr_reader :id, :elements, :edit

        [:h1, :h2, :h3, :h4, :h5, :h6, :p, :span, :div].each do |t|
          define_method(t) do |id, html_opts = {}|
            html_opts.merge!({class: "sb-#{t} #{html_opts[:class]}", data: {id: id}}) if edit
            content_tag(t, (elements.dig(id, "text") || "Texte à modifier"), html_opts)
          end
        end

        def initialize(id, elts, edit_mode)
          @id = id
          @elements = Hash[elts.map {|e| [e["id"], e.except("id")]}]
          @edit = edit_mode
        end

        def img(id, html_opts = {})
          if edit
            content_tag(:div, content_tag(:img, nil, (elements[id] || {"src" => "/default.jpg"}).merge(html_opts)),
                        {class: "sb-img #{html_opts[:class]}", data: {id: id}})
          else
            content_tag(:img, nil, (elements[id] || {"src" => "/default.jpg"}).merge(html_opts))
          end
        end

        def lnk(id)
          elements[id] || {"href" => "#", "text" => "Nouveau lien"}
        end

        def values(key, default_val)
          elements.any? ? elements.values.map {|v| v[key]} : [default_val]
        end

        def images
          values("src", "/default.jpg")
        end
      end

      def section(id, entity = @page, &block)
        s = SectionHelper.new(id, entity.section(id), action_name != 'show')
        if action_name == 'show'
          capture(s, &block)
        else
          "<sb-edit data-id='#{id}' data-entity='#{entity.is_a?(Sibu::Page) ? 'page' : 'site'}'>#{capture(s, &block)}</sb-edit>".html_safe
        end
      end
    end
  end
end
