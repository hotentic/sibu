require 'test_helper'

module Sibu
  class SiteTemplateTest < ActiveSupport::TestCase

    test "should list sections templates" do
      template = SiteTemplate.new(path: 'test')
      assert_equal [
                       {"id"=>"sibu_template_list_section_one", "category"=>"lists", "template"=>"list_section_one"},
                       {"id"=>"sibu_template_list_section_two", "category"=>"lists", "template"=>"list_section_two"},
                       {"id"=>"sibu_template_title_section", "category"=>"texts", "template"=>"title_section"},
                       {"id"=>"sibu_template_paragraph_section", "category"=>"texts", "template"=>"paragraph_section"}
                   ], template.available_sections
    end
  end
end
