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
      site = Site.new(name: 'test site', site_template: @site_template, sections: @site_sections, version: 'fr')
      page = Page.new(name: 'test page', site: site, template: 'test template', path: 'test',
                      sections: @page_sections)

      assert_equal true, site.save
      assert_equal @site_sections, site.sections
      assert_equal true, page.save
      assert_equal @page_sections, page.sections
    end

    test "section retrieval" do
      site = Site.create(name: 'test site', site_template: @site_template, sections: @site_sections)
      page = Page.create(name: 'test page', site: site, template: 'test template', path: 'test',
                         sections: @page_sections)

      assert_equal({"id" => "s1", "elements" => [{"id" => "text1", "value" => "value1"}]}, site.section("s1"))
      assert_equal({"id" => "s2", "elements" => [{"id" => "text2", "value" => "value2", "label" => "label2"}]}, site.section("s2"))
      assert_equal({"id" => "p1", "elements" => [{"id" => "text1", "value" => "value1"}]}, page.section("p1"))
      assert_equal({"id" => "p2", "elements" => [{"id" => "text2", "value" => "value2", "label" => "label2"}]}, page.section("p2"))
      assert_equal({"id" => "unknown"}, page.section("unknown"))
    end

    test "elements retrieval" do
      site = Site.create(name: 'test site', site_template: @site_template)
      page = Page.create(name: 'test page', site: site, template: 'test template', path: 'test',
                         sections: [{"id" => "p1", "elements" => [{"id" => "text1", "elements" => [{"id" => "elt1", "elements" => [{"id" => "elt2"}]}]}]}])
      assert_equal([{"id" => "text1", "elements" => [{"id" => "elt1", "elements" => [{"id" => "elt2"}]}]}], page.elements("p1"))
      assert_equal([{"id" => "elt1", "elements" => [{"id" => "elt2"}]}], page.elements("p1", "text1"))
      assert_equal([{"id" => "elt2"}], page.elements("p1", "text1", "elt1"))
      assert_equal([], page.elements("p1", "text1", "unknown"))
    end

    test "element retrieval" do
      site = Site.create(name: 'test site', site_template: @site_template)
      page = Page.create(name: 'test page', site: site, template: 'test template', path: 'test',
                         sections: [{"id" => "p1", "elements" => [{"id" => "text1", "elements" => [{"id" => "elt1"}]}]}])
      assert_equal({"id" => "p1", "elements" => [{"id" => "text1", "elements" => [{"id" => "elt1"}]}]}, page.element("p1"))
      assert_equal({"id" => "text1", "elements" => [{"id" => "elt1"}]}, page.element("p1", "text1"))
      assert_equal({"id" => "elt1"}, page.element("p1", "text1", "elt1"))
    end

    test "existing element update" do
      site = Site.new(name: 'test site', site_template: @site_template, sections: @site_sections)
      page = Page.new(name: 'test page', site: site, template: 'test template', path: 'test',
                      sections: @page_sections)

      assert_equal({"id" => "text1", "value" => "value2"}, page.update_element("p1", {"id" => "text1", "value" => "value2"}))
      assert_equal([{"id" => "p1", "elements" => [{"id" => "text1", "value" => "value2"}]},
                    {"id" => "p2", "elements" => [{"id" => "text2", "value" => "value2", "label" => "label2"}]}], page.sections)
    end

    test "new element update on existing node" do
      site = Site.new(name: 'test site', site_template: @site_template, sections: @site_sections)
      page = Page.new(name: 'test page', site: site, template: 'test template', path: 'test',
                      sections: @page_sections)
      assert_equal({"id" => "new", "value" => "new"}, page.update_element("p1", {"id" => "new", "value" => "new"}))
      assert_equal([{"id" => "p1", "elements" => [{"id" => "text1", "value" => "value1"}, {"id" => "new", "value" => "new"}]},
                    {"id" => "p2", "elements" => [{"id" => "text2", "value" => "value2", "label" => "label2"}]}], page.sections)

    end

    test "new element update on new node" do
      site = Site.new(name: 'test site', site_template: @site_template, sections: @site_sections)
      page = Page.new(name: 'test page', site: site, template: 'test template', path: 'test',
                      sections: @page_sections)
      assert_equal({"id" => "new", "value" => "new"}, page.update_element("p3", {"id" => "new", "value" => "new"}))
      assert_equal([{"id" => "p1", "elements" => [{"id" => "text1", "value" => "value1"}]},
                    {"id" => "p2", "elements" => [{"id" => "text2", "value" => "value2", "label" => "label2"}]},
                    {"id" => "p3", "elements" => [{"id" => "new", "value" => "new"}]}], page.sections)
    end

    test "new element update on new nested node" do
      site = Site.new(name: 'test site', site_template: @site_template, sections: @site_sections)
      page = Page.new(name: 'test page', site: site, template: 'test template', path: 'test',
                      sections: @page_sections)
      assert_equal({"id" => "new", "value" => "new"}, page.update_element("p3", "p4", {"id" => "new", "value" => "new"}))
      assert_equal([{"id" => "p1", "elements" => [{"id" => "text1", "value" => "value1"}]},
                    {"id" => "p2", "elements" => [{"id" => "text2", "value" => "value2", "label" => "label2"}]},
                    {"id" => "p3", "elements" => [{"id" => "p4", "elements" => [{"id" => "new", "value" => "new"}]}]}], page.sections)
    end
  end
end
