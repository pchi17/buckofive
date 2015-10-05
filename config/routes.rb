Rails.application.routes.draw do
  root 'polls#index'
  get    '/about'   => 'static_pages#about'
  get    '/help'    => 'static_pages#help'
  get    '/signup'  => 'users#new'
  get    '/login'   => 'sessions#new'
  post   '/login'   => 'sessions#create'
  delete '/logout'  => 'sessions#destroy'
  get    '/contact' => 'contacts#new'
  post   '/contact' => 'contacts#create'
  get    '/flags'   => 'flags#index'
  resources :users,               only: [:new, :create, :index, :destroy]
  resources :account_activations, only: [:create, :edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :polls, except: [:edit, :update] do
    member     { post 'vote' }
    member     { post 'flag' }
    collection { get  'flags' }
    resources :comments, only: [:create, :destroy]
  end
  resources :votes, only: :create

  resource :profile, only: :show do
    resource :info,     only: [:edit, :update]
    resource :password, only: [:edit, :update]
  end

  # OmniAuth
  get 'auth/twitter/callback' => 'authentications#twitter'
  get 'auth/failure'          => 'authentications#failure'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
