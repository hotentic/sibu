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
          logger.debug("init section #{ids[0]}")
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
        logger.debug("init section #{subid}")
        sub = {"id" => subid, "elements" => []}
        self.sections[id] << sub
        save
      end
      sub["elements"]
    end

    def element(*ids, element_id)
      elt = section(*ids).select {|e| e["id"] == element_id}.first
      elt || {"id" => element_id}
    end

    # Todo : add an "elements" method
    # and make section and subsection return sections

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

    def clone_section(*ids)
      siblings = section(ids.first)
      ref_index = siblings.index {|s| s["id"] == ids.last}
      new_section = siblings[ref_index].deep_dup
      new_section["id"] = ids.last + '§'
      siblings.insert(ref_index + 1, new_section)
      save ? new_section : nil
    end

    def delete_section(*ids)
      siblings = section(ids.first)
      if siblings.length == 1
        nil
      else
        ref_index = siblings.index {|s| s["id"] == ids.last}
        siblings.delete_at(ref_index)
        save
      end
    end

    def sanitize_value(value)
      unless value["text"].blank?
        value["text"].gsub!(/<\/?(div|p|ul|li)>/, '')
      end
    end
  end
end