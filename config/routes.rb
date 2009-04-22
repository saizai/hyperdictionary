ActionController::Routing::Routes.draw do |map|
  map.rpx_login '/rpx_login', :controller => 'users', :action => 'rpx_login'
  map.resources :users, :member => { :forgot_password => :get, :change_password => :put }
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login  '/login',  :controller => 'sessions', :action => 'new'
  map.signup  '/signup', :controller => 'users',   :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.reset_password '/reset_password/:password_reset_code', :controller => 'users', :action => 'reset_password', :password_reset_code => nil
  map.resource :session

  map.namespace :admin do |admin|
    admin.root :controller => 'main'
    admin.resources :four_oh_fours
    admin.resources :users, :member => {:suspend => :put, :unsuspend => :put, :purge => :delete, :activate => :put, 
                                        :add_role => :put, :remove_role => :delete, :unmap => :delete, :map => :put,
                                        :reset => :put } do |users|
      users.resources :roles
    end
  end
  map.admin_logged_exceptions "/admin/logged_exceptions/:action/:id", :controller => "logged_exceptions"
  
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"
  map.home '/home', :controller => 'main', :action => 'home'
  map.about '/about', :controller => 'main', :action => 'about'
  map.root :controller => "main"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
#  map.connect ':controller/:id/:action'
#  map.connect ':controller/:id/:action.:format'
  map.connect '*path' , :controller => 'four_oh_fours', :action => 'log'
end
