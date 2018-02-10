class DummyUser
  attr_accessor :id

  def initialize(id)
    @id = id
  end
end

DEFAULT_USER = DummyUser.new(1)

# Note : requires to restart in dev mode when a sibu controller is updated
ActiveSupport.on_load(:action_controller) do
  Sibu::ApplicationController.class_eval do
    def dummy_auth
    end

    def dummy_user
      DEFAULT_USER
    end
  end
end

class DefaultSite
  def sections(site)
    {}
  end

  def pages
    [{name: 'Home', template: 'test', path: '', language: 'en', sections: {}}]
  end
end

Rails.application.config.sibu = {
    title: 'Sibu test site',
    stylesheet: 'application',
    javascript: 'application',
    top_panel: 'shared/top_panel',
    content_panel: 'shared/content_panel',
    bottom_panel: 'shared/bottom_panel',
    auth_filter: :dummy_auth,
    current_user: :dummy_user,
    domain: 'localhost',
    not_found: 'shared/not_found',
    site_data: {default: DefaultSite.new},
    images: {large: 1024, medium: 640, small: 320}
}
