require 'test_helper'

module Sibu
  class PagesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      Sibu::ApplicationController.class_eval do
        def dummy_auth
        end

        def dummy_user
          DEFAULT_USER
        end
      end
    end

    test "should get sites" do
      get 'http://localhost:3000/sites'
      assert_response :success
    end

    test "should get site pages" do
      site = sibu_sites(:site_one)
      get "http://localhost:3000/sites/#{site.id}/pages"
      assert_response :success
    end

    test "should get site page" do
      site = sibu_sites(:site_one)
      page = sibu_pages(:page_one)
      get "http://localhost:3000/sites/#{site.id}/pages/#{page.id}"
      assert_response :success
      assert_select "title", "Page one"
    end

    test "should get site page with trailing /" do
      site = sibu_sites(:site_one)
      page = sibu_pages(:page_one)
      get "http://localhost:3000/sites/#{site.id}/pages/#{page.id}/"
      assert_response :success
      assert_select "title", "Page one"
    end

    test "should match existing page on published site" do
      get 'http://www.published.site/segment1/segment2'
      assert_response :success
      assert_select "title", "Page one"
      assert_nil controller.instance_variable_get(:@query_path)
      assert_empty controller.instance_variable_get(:@query_params)
    end

    test "should match existing page with path params on published site" do
      get 'http://www.published.site/segment1/segment2/param1/param2'
      assert_response :success
      assert_select "title", "Page one"
      assert_equal 'param1/param2', controller.instance_variable_get(:@query_path)
      assert_empty controller.instance_variable_get(:@query_params)
    end

    test "should match existing page with query params on published site" do
      get 'http://www.published.site/segment1/segment2/segment3?param1=param2&param3=param4'
      assert_response :success
      assert_select "title", "Page one"
      assert_equal 'segment3', controller.instance_variable_get(:@query_path)
      assert_equal({'param1' => 'param2', 'param3' => 'param4'}, controller.instance_variable_get(:@query_params))
    end

    test "should match home page on published site" do
      get 'http://www.published.site'
      assert_response :success
      assert_select "title", "Home page"
      assert_nil controller.instance_variable_get(:@query_path)
      assert_empty controller.instance_variable_get(:@query_params)
    end

    test "should match home page with trailing / on published site" do
      get 'http://www.published.site/'
      assert_response :success
      assert_select "title", "Home page"
      assert_nil controller.instance_variable_get(:@query_path)
      assert_empty controller.instance_variable_get(:@query_params)
    end

    test "should match home page with query params on published site" do
      get 'http://www.published.site?param1=param2'
      assert_response :success
      assert_select "title", "Home page"
      assert_nil controller.instance_variable_get(:@query_path)
      assert_equal({'param1' => 'param2'}, controller.instance_variable_get(:@query_params))
    end

    test "should return 404 on missing page" do
      get 'http://www.published.site/unknown/page'
      assert_response :not_found
    end
  end
end
