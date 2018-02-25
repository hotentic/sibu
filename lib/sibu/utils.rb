module Sibu
  class Utils
    def self.convert_sections
      Sibu::Site.all.each do |s|
        sections = s.sections
        s.update(sections: sections.keys.map {|k| {id: k, elements: sections[k]}})
      end

      Sibu::Page.all.each do |p|
        sections = p.sections
        p.update(sections: sections.keys.map {|k| {id: k, elements: sections[k]}})
      end
    end
  end
end