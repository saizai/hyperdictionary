ActionController::Routing::Routes.draw do |map|
  map.resource :session # For the unitary session, i.e. the current one
  map.resources :users, :member => {:forgot_password => :get, :change_password => :put, :set_preference => :put, :set_user_name => :post} do |user|
    user.resources :contacts, :member => {:activate => :get, :screen => :put, :verify => :put, :suspend => :put} # technically activate should be a put, but accessed via get... oh well
    user.resources :relationships, :member => {:confirm => :put} 
    user.resources :sessions # For all the user's sessions
    user.resource :page, :member => {:change_role => :put, :subscribe => :put} do |page|
      page.resources :comments, :member => {:moderate => :put, :screen => :put}
      page.resources :versions, :member => {:compare => :get, :revert => :put}
    end
    user.resources :tags
    user.resources :assets, :collection => {:swfupload => :post}, :member => {:download => :get}
    user.resources :identities, :member => {:screen => :put}
  end
  
  # For global ones:
  map.resources :tags
  map.resources :pages, :member => {:change_role => :put, :subscribe => :put} do |page|
    page.resources :comments, :member => {:moderate => :put, :screen => :put }
    page.resources :versions, :member => {:compare => :get, :revert => :put}
  end
  # only used because polymorphic parent URLs are a pain in the ass (e.g. moderate_???_comment_url)
  map.resources :comments, :member => {:moderate => :put, :screen => :put }
  
  map.rpx_login '/rpx_login', :controller => 'users', :action => 'rpx_login'
  map.rpx_add '/rpx_add', :controller => 'users', :action => 'rpx_add'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login  '/login',  :controller => 'sessions', :action => 'new'
  map.signup  '/signup', :controller => 'users',   :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password'
  map.reset_password '/reset_password/:password_reset_code', :controller => 'users', :action => 'reset_password', :password_reset_code => nil
# Deprecated for contact verification
#  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  
  map.namespace :admin do |admin|
    admin.root :controller => 'main'
    admin.preferences 'preferences', :controller => 'main', :action => 'preferences'
    admin.resources :four_oh_fours
    admin.resources :users, :member => {:suspend => :put, :unsuspend => :put, :purge => :delete, :activate => :put, 
                                        :add_role => :put, :remove_role => :delete, :unmap => :delete, :map => :put,
                                        :reset => :put,  :same_ip => :get },
                            # Spoof is really a member function, but we don't know which member until after runtime, so we can't require ID
                            :collection => {:spoof => :put} do |users|
      users.resources :roles
    end
     admin.logged_exceptions "/logged_exceptions/:action/:id", :controller => "logged_exceptions"
  end
  
  map.home '/home', :controller => 'main', :action => 'home'
  map.about '/about', :controller => 'main', :action => 'about'
  map.root :controller => "main"

# Don't allow wildcard routes - log 'em as 404s instead
#  map.connect ':controller/:id/:action'
#  map.connect ':controller/:id/:action.:format'
  map.connect '*path' , :controller => 'four_oh_fours', :action => 'log'
end
