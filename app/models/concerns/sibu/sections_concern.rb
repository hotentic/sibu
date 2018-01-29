module Sibu
  module SectionsConcern
    include ActiveSupport::Concern

    def section(*ids)
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
        s = section(ids[0])
        sub = s.select {|elt| elt["id"] == ids[1]}
        unless sub
          sub = {"id" => ids[1], "elements" => []}
          self.sections[ids[0]] << sub
          save
        end
        sub
      end
    end

    def element(section_id, element_id)
      elt = section(section_id).select {|e| e["id"] == element_id}.first
      elt || {}
    end

    def update_section(*ids, value)
    end

    # Note : only 2 levels supported for now
    def update_element(*ids, value)
      updated = nil
      if ids.length > 1
        if self.sections[ids[0]].any? {|elt| elt["id"] == ids[1]}
          self.sections[ids[0]].map! {|elt| elt["id"] == ids[1] ? elt.value : elt}
        else
          self.sections[ids[0]] << {"id" => ids[1]}.merge(value)
        end
        updated = value if save
      end
      updated
    end
  end
end