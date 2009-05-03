# Add to the User model:
#     acts_as_authorized_user
#     acts_as_authorizable  # also add this to other models that take roles

module Authorization
  module Base
    # suppress redefinition warnings in case we load after the plugin does
    remove_const :AUTHORIZATION_MIXIN if defined? AUTHORIZATION_MIXIN
    remove_const :LOGIN_REQUIRED_REDIRECTION if defined? LOGIN_REQUIRED_REDIRECTION
    remove_const :PERMISSION_DENIED_REDIRECTION if defined? PERMISSION_DENIED_REDIRECTION
    remove_const :STORE_LOCATION_METHOD if defined? STORE_LOCATION_METHOD
    
    # Can be 'object roles' or 'hardwired'
    AUTHORIZATION_MIXIN = "object roles"
    # NOTE : If you use modular controllers like '/admin/products' be sure
    # to redirect to something like '/sessions' controller (with a leading slash)
    # as shown in the example below or you will not get redirected properly
    #
    # This can be set to a hash or to an explicit path like '/login'
    LOGIN_REQUIRED_REDIRECTION = '/login' # { :controller => '/sessions', :action => 'new' }
    PERMISSION_DENIED_REDIRECTION = { :controller => '/main', :action => 'index' }
    # The method your auth scheme uses to store the location to redirect back to
    STORE_LOCATION_METHOD = :store_location
  end
end