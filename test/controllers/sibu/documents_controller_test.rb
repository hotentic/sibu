require 'test_helper'

module Sibu
  class DocumentsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get index" do
      get documents_index_url
      assert_response :success
    end

    test "should get new" do
      get documents_new_url
      assert_response :success
    end

    test "should get create" do
      get documents_create_url
      assert_response :success
    end

  end
end
