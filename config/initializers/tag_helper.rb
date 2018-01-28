module ActionView
  module Helpers
    module TagHelper
      class Section
        include ActionView::Helpers::TagHelper

        attr_reader :id, :elements, :edit

        [:h1, :h2, :h3, :h4, :h5, :h6, :p, :span, :div].each do |t|
          define_method(t) do |id, cl = ''|
            content_tag(t, (elements.dig(id, "value") || "Texte à modifier"), class: (edit ? [cl, "sb-#{t}"].join(' ') : cl))
          end
        end

        def initialize(hsh, edit_mode)
          @id = hsh["id"]
          @elements = Hash[hsh["elements"].map {|e| [e["id"], e]}]
          @edit = edit_mode
        end

        def img(id)
          elements.dig(id, "value") || "/default.jpg"
        end

        def lnk(id)
          elements[id] || {"value" => "#", "label" => "Nouveau lien"}
        end

        def values(default_val)
          elements.any? ? elements.values.map {|v| v["value"]} : [default_val]
        end

        def images
          values("/default.jpg")
        end
      end

      def section(id, entity = @page, &block)
        s = Section.new(entity.section(id), action_name != 'show')
        if action_name == 'show'
          capture(s, &block)
        else
          "<sb-edit>#{capture(s, &block)}</sb-edit>".html_safe
        end
      end
    end
  end
end
