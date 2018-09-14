require 'test_helper'

module Sibu
  class RoutingTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @routes = Sibu::Engine.routes
    end

    test "should recognize a published site page" do
      assert_recognizes({controller: 'sibu/pages', action: 'show'}, '/')
      assert_recognizes({controller: 'sibu/pages', action: 'show', path: 'segment1/segment2'}, '/segment1/segment2')
    end

    test "should return edit action" do
      assert_recognizes({controller: 'sibu/pages', action: 'edit', site_id: '2', id: '323'}, 'http://localhost:3000/sites/2/pages/323/parametrer')
    end

  end
end