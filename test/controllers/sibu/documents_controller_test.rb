require 'test_helper'

module Sibu
  class DocumentsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get index" do
      get documents_url
      assert_response :success
    end

    test "should get new" do
      get new_document_url
      assert_response :success
    end

  end
end
