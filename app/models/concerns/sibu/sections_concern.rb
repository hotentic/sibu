module Sibu
  module SectionsConcern
    include ActiveSupport::Concern

    def section(id)
      s = nil
      if sections.blank?
        self.sections = {}
      else
        s = sections[id]
      end
      if s.nil?
        s = []
        self.sections[id] = s
        save
      end
      s
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