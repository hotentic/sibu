module ActionView
  module Helpers
    module TagHelper
      class SectionHelper
        include ActionView::Helpers::TagHelper

        attr_reader :id, :elements, :edit

        [:h1, :h2, :h3, :h4, :h5, :h6, :p, :span, :div].each do |t|
          define_method(t) do |id, cl = nil|
            html_opts = edit ? {class: "sb-#{t} #{cl}", data: {id: id}} : (cl ? {class: cl} : {})
            content_tag(t, (elements.dig(id, "text") || "Texte à modifier"), html_opts)
          end
        end

        def initialize(id, elts, edit_mode)
          @id = id
          @elements = Hash[elts.map {|e| [e["id"], e]}]
          @edit = edit_mode
        end

        def img(id)
          elements.dig(id, "src") || "/default.jpg"
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
