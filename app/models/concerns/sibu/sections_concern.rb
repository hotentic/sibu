module Sibu
  module SectionsConcern
    include ActiveSupport::Concern

    def section(id)
      if id
        pos = sections.index {|s| s["id"] == id}
        pos ? sections[pos] : {"id" => id}
      end
    end

    def elements(*ids)
      unless ids.blank?
        s = section(ids.first)
        unless s["elements"].blank?
          ids[1..-1].each do |elt_id|
            pos = s["elements"].index {|e| e["id"] == elt_id.split('|').last}
            s = pos ? s["elements"][pos] : {"id" => elt_id, "elements" => []}
          end
          s["elements"]
        end
      end
    end

    def element(*ids)
      unless ids.blank?
        if ids.length == 1
          section(ids.first)
        else
          elts = elements(*ids[0..-2]) || []
          pos = elts.index {|e| e["id"] == ids.last}
          pos ? elts[pos] : {"id" => ids.last}
        end
      end
    end

    def update_element(*ids, value)
      unless ids.blank?
        parent_section = find_or_init(*ids)["elements"]
        if parent_section.any? {|elt| elt["id"] == value["id"]}
          parent_section.map! {|elt| elt["id"] == value["id"] ? value : elt}
        else
          parent_section << value.to_h
        end

        value if save
      end
    end

    def clone_element(*ids, element_id)
      src_elt = find_or_init(*ids, element_id)
      siblings = find_or_init(*ids)["elements"]
      ref_index = siblings.index {|s| s["id"] == element_id}
      new_elt = siblings[ref_index].deep_dup
      new_elt["id"] = "cl#{Time.current.to_i}"
      siblings.insert(ref_index + 1, new_elt)
      save ? new_elt : nil
    end

    def delete_element(*ids, element_id)
      src_elt = find_or_init(*ids, element_id)
      siblings = find_or_init(*ids)["elements"]
      ref_index = siblings.index {|s| s["id"] == element_id}
      siblings.delete_at(ref_index)
      save
    end

    def child_element(*ids, element_id)
      siblings = elements(*ids)
      parent_elt = siblings[siblings.index {|s| s["id"] == element_id}]
      if parent_elt["elements"].blank?
        parent_elt["elements"] = [{"id" => "cl#{Time.current.to_i}"}]
      else
        parent_elt["elements"] << {"id" => "cl#{Time.current.to_i}"}
      end
      save
    end

    def create_section(*ids, after, new_section)
      new_section["id"] = "cs#{Time.current.to_i}"
      if ids.length == 1
        parent = sections
      else
        parent = find_or_init(*ids[0..-2])["elements"]
      end
      if new_section["template"].blank?
        nil
      else
        template_defaults = (site_template.templates && site_template.templates[new_section["template"]]) ? site_template.templates[new_section["template"]] : {}
        sec = template_defaults.merge(new_section)
        ref_pos = parent.index {|s| s["id"] == ids.last}
        parent.insert(after.to_s == 'true' ? ref_pos + 1 : ref_pos, sec)
        sec if save
      end
    end

    def delete_section(*ids)
      if ids.length == 1
        if sections.length == 1
          nil
        else
          ref_index = sections.index {|s| s["id"] == ids.first}
          sections.delete_at(ref_index)
          save
        end
      else
        parent = find_or_init(*ids[0..-2])
        ref_index = parent["elements"].index {|s| s["id"] == ids.last}
        parent["elements"].delete_at(ref_index)
        save
      end
    end

    def elt(siblings, elt_id, default_elt = nil)
      pos = siblings.index {|e| e["id"] == elt_id}
      pos ? siblings[pos] : default_elt
    end

    def find_or_init(*ids)
      node = nil
      siblings = sections
      ids.each do |elt_id|
        node = elt(siblings, elt_id)
        if node.nil?
          node = {"id" => elt_id, "elements" => []}
          siblings << node
        elsif node["elements"].nil?
          node["elements"] = []
        end
        siblings = node["elements"]
      end
      node
    end

    def has_section?(section_id)
      sections && sections.find {|s| s['id'] == section_id}
    end
  end
end