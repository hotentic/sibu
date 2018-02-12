module Sibu
  module SectionsConcern
    include ActiveSupport::Concern

    def section(*ids)
      # elts = nil
      if ids.length == 1
        s = nil
        if sections.blank?
          self.sections = {}
        else
          s = sections[ids[0]]
        end
        if s.nil?
          s = []
          self.sections[ids[0]] = s
          save
        end
        s
      elsif ids.length == 2
        subsection(*ids)
      end
    end

    def subsection(id, subid)
      s = section(id)
      sub_idx = s.index {|elt| elt["id"] == subid}
      if sub_idx
        sub = s[sub_idx]
      else
        sub = {"id" => subid, "elements" => []}
        self.sections[id] << sub
        save
      end
      sub["elements"]
    end

    def element(*ids, element_id)
      elt = section(*ids).select {|e| e["id"] == element_id}.first
      elt || {}
    end

    def update_section(*ids, value)
    end

    def update_element(*ids, value)
      sanitize_value(value)
      parent_section = section(*ids)
      if parent_section.any? {|elt| elt["id"] == value["id"]}
        parent_section.map! {|elt| elt["id"] == value["id"] ? value : elt}
      else
        parent_section << value
      end

      value if save
    end

    def sanitize_value(value)
      unless value["text"].blank?
        value["text"].gsub!(/<\/?(div|p|ul|li)>/, '')
      end
    end
  end
end