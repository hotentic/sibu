module Sibu
  module PagesHelper
    def section(id, entity = @page, &block)
      s = entity.section(id)
      hsh = Hash[s.map {|e| [e["id"], e]}]
      hsh.default_proc = -> (h, k) { h[k] = {"id" => k, "value" => "Texte"}}
      "<sb-edit>#{capture(hsh, &block)}</sb-edit>".html_safe
    end
  end
end
