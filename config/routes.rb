Sibu::Engine.routes.draw do

  get '/', to: 'pages#show', constraints: lambda {|req| req.domain != Rails.application.config.sibu_domain}
  get '*path', to: 'pages#show', constraints: lambda {|req| req.domain != Rails.application.config.sibu_domain}

  scope path_names: {new: 'creer', edit: 'modifier'} do
    resources :sites do
      resource :pages
    end
  end
end
