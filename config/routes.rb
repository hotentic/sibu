Sibu::Engine.routes.draw do

  scope format: true, constraints: { format: /jpg|png|gif|svg/ } do
    get '/*missed', to: proc { [404, {}, ['']] }
  end
  get '/', to: 'pages#show', constraints: lambda {|req| req.host != Rails.application.config.sibu[:host]}
  get '*path', to: 'pages#show', constraints: lambda {|req| req.host != Rails.application.config.sibu[:host]}

  scope path_names: {new: 'creer', edit: 'parametrer'} do
    resources :sites do
      post 'duplicate', on: :member
      resources :pages do
        post 'duplicate', on: :member
        get :edit_content, to: 'pages#edit_content', path: 'editer'
        get :edit_element, on: :member
        get :edit_section, on: :member
        patch 'update_element', on: :member
        patch 'update_section', on: :member
        post 'clone_element', on: :member
        delete 'delete_element', on: :member
        post 'child_element', on: :member
        get 'new_section', on: :member
        post 'create_section', on: :member
        delete 'delete_section', on: :member
      end
      resources :pages, only:[] do
        get '*path', to: 'pages#show', on: :member
      end

    end
    resources :images, :documents
  end
end
