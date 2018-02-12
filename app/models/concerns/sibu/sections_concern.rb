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
      sub = s.select {|elt| elt["id"] == subid}.first
      unless sub
        sub = {"id" => subid, "elements" => []}
        self.sections[id] << sub
        save
      end
      sub["elements"]
    end

    def element(section_id, element_id)
      elt = section(section_id).select {|e| e["id"] == element_id}.first
      elt || {}
    end

    def update_section(*ids, value)
    end

    def update_element(section_id, value)
      sanitize_value(value)
      if self.sections[section_id].any? {|elt| elt["id"] == value["id"]}
        self.sections[section_id].map! {|elt| elt["id"] == value["id"] ? value : elt}
      else
        self.sections[section_id] << value
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