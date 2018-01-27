require 'test_helper'

module Sibu
  class PageTest < ActiveSupport::TestCase

    setup do
      @site_template = SiteTemplate.create(name: 'test', path: 'test')
      @site_sections = [
          {"id" => "s1", "elements" => [{"id" => "text1", "value" => "value1"}]},
          {"id" => "s2", "elements" => [{"id" => "text2", "value" => "value2", "label" => "label2"}]}
      ]
      @page_sections = [
          {"id" => "p1", "elements" => [{"id" => "text1", "value" => "value1"}]},
          {"id" => "p2", "elements" => [{"id" => "text2", "value" => "value2", "label" => "label2"}]}
      ]
    end

    test "basic sections serialization" do
      site = Site.new(name: 'test site', site_template: @site_template, sections: @site_sections)
      page = Page.new(name: 'test page', site: site, template: 'test template', path: 'test', language: 'fr',
                      sections: @page_sections)

      assert_equal true, site.save
      assert_equal @site_sections, site.sections
      assert_equal true, page.save
      assert_equal @page_sections, page.sections
    end

    test "section retrieval" do
      site = Site.create(name: 'test site', site_template: @site_template, sections: @site_sections)
      page = Page.create(name: 'test page', site: site, template: 'test template', path: 'test', language: 'fr',
                         sections: @page_sections)

      assert_equal [{"id" => "text1", "value" => "value1"}], site.section("s1")
      assert_equal [{"id" => "text2", "value" => "value2", "label" => "label2"}], site.section("s2")
      assert_equal [{"id" => "text1", "value" => "value1"}], page.section("p1")
      assert_equal [{"id" => "text2", "value" => "value2", "label" => "label2"}], page.section("p2")
      assert_equal [], page.section("unknown")
    end
  end
end
