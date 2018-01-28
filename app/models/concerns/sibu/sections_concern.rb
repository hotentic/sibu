module Sibu
  module SectionsConcern
    include ActiveSupport::Concern

    def section(id)
      s = nil
      if sections.blank?
        self.sections = []
      else
        s = sections.select {|sc| sc["id"] == id}.first
      end
      if s.nil?
        s = {"id" => id, "elements" => []}
        self.sections << s
        save
      end
      s
    end

    def element(section_id, element_id)
      elt = section(section_id).select {|e| e["id"] == element_id}.first
      elt || {}
    end

    def update_section(*ids, value)
    #   Todo
    end
  end
end