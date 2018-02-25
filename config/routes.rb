Sibu::Engine.routes.draw do

  get '/', to: 'pages#show', constraints: lambda {|req| req.domain != Rails.application.config.sibu[:domain]}
  get '*path', to: 'pages#show', constraints: lambda {|req| req.domain != Rails.application.config.sibu[:domain]}

  scope path_names: {new: 'creer', edit: 'modifier'} do
    resources :sites do
      resources :pages do
        get :edit_content, to: 'pages#edit_content', path: 'editer'
        get :edit_element, on: :member
        get :edit_section, on: :member
        patch 'update_element', on: :member
        post 'clone_element', on: :member
        delete 'delete_element', on: :member
        post 'child_element', on: :member
        get 'new_section', on: :member
        post 'create_section', on: :member
        delete 'delete_section', on: :member
      end

      resources :images
    end
  end
end
