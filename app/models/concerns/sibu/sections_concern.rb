module Sibu
  module SectionsConcern
    include ActiveSupport::Concern

    def section(id)
      # elts = nil
      # if ids.length == 1
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
      # elsif ids.length == 2
      #   s = section(ids[0])
      #   sub = s.select {|elt| elt["id"] == ids[1]}
      #   unless sub
      #     sub = {"id" => ids[1], "elements" => []}
      #     self.sections[ids[0]] << sub
      #     save
      #   end
      #   elts = sub
      # end
      # elts.blank? ? {"default" => {}} : Hash[elts.map {|e| [e["id"], e.except("id")]}]
    end

    def subsection(id, subid)
      s = section(id)
      sub = s.select {|elt| elt["id"] == ids[1]}
      unless sub
        sub = {"id" => ids[1], "elements" => []}
        self.sections[ids[0]] << sub
        save
      end
      elts = sub
    end

    def element(section_id, element_id)
      elt = section(section_id)[element_id]
      elt || {}
    end

    def update_section(*ids, value)
    end

    # Note : only 2 levels supported for now
    def update_element(section_id, value)
      if self.sections[section_id].any? {|elt| elt["id"] == value["id"]}
        self.sections[section_id].map! {|elt| elt["id"] == value["id"] ? value : elt}
      else
        self.sections[section_id] << value
      end
      value if save
    end
  end
end