require 'test_helper'

module Sibu
  class PagesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get index" do
      get pages_index_url
      assert_response :success
    end

    test "should get show" do
      get pages_show_url
      assert_response :success
    end

    test "should get edit" do
      get pages_edit_url
      assert_response :success
    end

    test "should get update" do
      get pages_update_url
      assert_response :success
    end

    test "should get destroy" do
      get pages_destroy_url
      assert_response :success
    end

  end
end
