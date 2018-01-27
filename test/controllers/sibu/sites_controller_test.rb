require 'test_helper'

module Sibu
  class SitesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get index" do
      get sites_index_url
      assert_response :success
    end

    test "should get show" do
      get sites_show_url
      assert_response :success
    end

    test "should get edit" do
      get sites_edit_url
      assert_response :success
    end

    test "should get update" do
      get sites_update_url
      assert_response :success
    end

    test "should get destroy" do
      get sites_destroy_url
      assert_response :success
    end

  end
end
