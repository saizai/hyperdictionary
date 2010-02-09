Hyperdictionary::Application.routes.draw do
  resource :session  # For the unitary session, i.e. the current users's current session
  resources :users, :has_many => [:badgings, :participations, :sessions, :tags] do
    member { get :forgot_password; put :change_password, :set_preference; post :set_user_name }
    collection { get :search }
    
    resources :assets { collection{ post :swfupload }; member{ get :download }}
    # technically activate should be a put, but accessed via get 'cause it's from email... oh well
    resources :contacts { member{get :activate; put :screen; put :verify; put :suspend } }
    # inbox
    resources :discussions, :has_many => :messages, :has_one => :participation
    resources :identities { member { put :screen }}
    resource :page, :has_many => :fora do
      member  { put :change_role, :subscribe }
      resources :messages { member{ put :moderate, :screen }}
      resources :versions { member{ get :compare; put :revert }}
    end
    resources :relationships { member{ put :confirm }}
  end
  
  resources :tags
  resources :badge_sets, :has_many => :badges
  resources :badges
  resources :pages, :has_many => :fora do
    member { put :change_role, :subscribe }
    resources :discussions, :has_many => [:messages, :participations]
    # This is for the page's special wall discussion. For other ones, go through its discussions.
    resources :messages { member { put :moderate, :screen }}
    resources :versions { member { get :compare; put :revert }}
  end

  resources :fora, :has_many => :fora
  resources :discussions, :has_many => :participations do
    resources :messages { member { put :moderate, :screen }}
  end
  
  resources :messages { collection { put :render_markdown}; member {put :moderate, :screen}}
  resources :events
  
  match '/rpx_login' => 'users#rpx_login', :as => :rpx_login
  match '/rpx_add' => 'users#rpx_add', :as => :rpx_add
  match '/logout' => 'sessions#destroy', :as => :logout
  match '/login' => 'sessions#new', :as => :login
  match '/signup' => 'users#new', :as => :signup
  match '/register' => 'users#create', :as => :register
  match '/forgot_password' => 'users#forgot_password', :as => :forgot_password
  match '/reset_password/:password_reset_code' => 'users#reset_password', :as => :reset_password #, :password_reset_code => nil
  
  namespace :admin, :has_many => :four_oh_fours do
    root :to => 'main#index'
    match 'admin_mode' => 'main#admin_mode', :as => :admin_mode, :method => 'put'
    match 'preferences' => 'main#preferences', :as => :preferences
    resources :users, :has_many => :roles do
      member do 
        put :suspend, :unsuspend, :activate, :add_role, :map, :reset
        get :same_ip
        delete :unmap, :remove_role, :purge
      end
      # Spoof is really a member function, but we don't know which member until after runtime, so we can't require ID
      collection { put :spoof }
    end
    match '/logged_exceptions/:action/:id' => 'logged_exceptions#index', :as => :logged_exceptions
  end
  
  match '/home' => 'main#home', :as => :home
  match '/about' => 'main#about', :as => :about
  root :to => 'main#index'
  
  # Don't allow wildcard routes - log 'em as 404s instead
  match '*path' => 'four_oh_fours#log'
end
