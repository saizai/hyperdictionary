require File.dirname(__FILE__) + '/publishare/exceptions'
require File.dirname(__FILE__) + '/publishare/parser'

module Authorization
  module Base

    # Modify these constants in your environment.rb to tailor the plugin to
    # your authentication system
    if not Object.constants.include? "LOGIN_REQUIRED_REDIRECTION"
      LOGIN_REQUIRED_REDIRECTION = {
        :controller => 'session',
        :action => 'new'
      }
    end
    if not Object.constants.include? "PERMISSION_DENIED_REDIRECTION"
      PERMISSION_DENIED_REDIRECTION = ''
    end
    if not Object.constants.include? "STORE_LOCATION_METHOD"
      STORE_LOCATION_METHOD = :store_location
    end

    def self.included( recipient )
      recipient.extend( ControllerClassMethods )
      recipient.class_eval do
        include ControllerInstanceMethods
      end
    end

    module ControllerClassMethods

      # Allow class-level authorization check.
      # permit is used in a before_filter fashion and passes arguments to the before_filter.
      def permit( authorization_expression, *args )
        filter_keys = [ :only, :except ]
        filter_args, eval_args = {}, {}
        if args.last.is_a? Hash
          filter_args.merge!( args.last.reject {|k,v| not filter_keys.include? k } )
          eval_args.merge!( args.last.reject {|k,v| filter_keys.include? k } )
        end
        before_filter( filter_args ) do |controller|
          controller.permit( authorization_expression, eval_args )
        end
      end
    end

    module ControllerInstanceMethods
      include Authorization::Base::EvalParser  # RecursiveDescentParser is another option
      
      # BE CAREFUL!
      
      # Remember that we're in the global controller namespace here, so be careful with instance variables and make sure we're only touching only our stuff.
      # NOTE: Under some conditions (like admins' user spoofing) @current_user != current_user (the function). Don't make assumptions and touch @current_user directly!
      
      # Permit? turns off redirection by default and takes no blocks
      def permit?( authorization_expression, *args )
        @railsauth_options = { :allow_guests => false, :redirect => false }
        @railsauth_options.merge!( args.last.is_a?( Hash ) ? args.last : {} )

        has_permission?( authorization_expression )
      end

      # Allow method-level authorization checks.
      # permit (without a question mark ending) calls redirect on denial by default.
      # Specify :redirect => false to turn off redirection.
      def permit( authorization_expression, *args )
        @railsauth_options = { :allow_guests => false, :redirect => true }
        @railsauth_options.merge!( args.last.is_a?( Hash ) ? args.last : {} )

        if has_permission?( authorization_expression )
          yield if block_given?
        elsif @railsauth_options[:redirect]
          handle_redirection
        end
      end

      private

      def has_permission?( authorization_expression )
        # If we're passed a non-String, just treat it as a direct value
        return authorization_expression unless authorization_expression.is_a? String
        
        @railsauth_current_user = get_user
        unless @railsauth_options[:allow_guests] or authorization_expression =~ /guest/ or defined? AnonUser
          # We aren't logged in, or an exception has already been raised.
          # Test for both nil and :false symbol as restful_authentication plugin
          # will set current user to ':false' on a failed login (patch by Ho-Sheng Hsiao).
          # Latest incarnations of restful_authentication plugin set current user to false.
          if @railsauth_current_user.nil? || @railsauth_current_user == :false || @railsauth_current_user == false
            return false
          elsif not @railsauth_current_user.respond_to? :id
            raise( UserDoesntImplementID, "User doesn't implement #id")
          elsif not @railsauth_current_user.respond_to? :has_role?
            raise( UserDoesntImplementRoles, "User doesn't implement #has_role?" )
          end
        end
        parse_authorization_expression( authorization_expression )
      end

      # Handle redirection within permit if authorization is denied.
      def handle_redirection
        respond_to do |format|
          format.html do
            return if not self.respond_to?( :redirect_to )

            # Store url in session for return if this is available from
            # authentication
            send( STORE_LOCATION_METHOD ) if respond_to? STORE_LOCATION_METHOD
            if @railsauth_current_user && @railsauth_current_user != :false
              flash[:notice] = @railsauth_options[:permission_denied_message] || "Permission denied. You cannot access the requested page."
              redirect_to @railsauth_options[:permission_denied_redirection] || PERMISSION_DENIED_REDIRECTION
            else
              flash[:notice] = @railsauth_options[:login_required_message] || "Login is required to access the requested page."
              redirect_to @railsauth_options[:login_required_redirection] || LOGIN_REQUIRED_REDIRECTION
            end
            false  # Want to short-circuit the filters
          end
          format.js   { render(:update) { |page| page.alert "Permission denied." } }
          format.xml  { head :forbidden }
          format.json { head :forbidden }
        end
      end
      
      # Try to find current user by checking options hash and instance method in that order.
      def get_user
        if @railsauth_options[:user]
          @railsauth_options[:user]
        elsif @railsauth_options[:get_user_method]
          send( @railsauth_options[:get_user_method] )
        elsif self.respond_to? :current_user
          current_user 
        elsif not @railsauth_options[:allow_guests]
          raise( CannotObtainUserObject, "Couldn't find #current_user or @user, and nothing appropriate found in hash" )
        end
      end
      
      # Try to find a model to query for permissions
      def get_model( str )
        if str =~ /\s*([A-Z]+\w*)\s*/
          # Handle model class
          begin
            Module.const_get( str )
          rescue
            raise CannotObtainModelClass, "Couldn't find model class: #{str}"
          end
        elsif str =~ /\s*:*(\w+)\s*/
          # Handle model instances
          model_name = $1
          model_symbol = model_name.to_sym
          if @railsauth_options[model_symbol]
            @railsauth_options[model_symbol]
          elsif instance_variables.include?( '@'+model_name )
            instance_variable_get( '@'+model_name )
          elsif respond_to?(model_symbol)
            send(model_symbol)
          # Note -- while the following code makes autodiscovery more convenient, it's a little too much side effect & security question
          # elsif self.params[:id]
          #  eval_str = model_name.camelize + ".find(#{self.params[:id]})"
          #  eval eval_str
          else
            raise CannotObtainModelObject, "Couldn't find model (#{str}) in hash or as an instance variable"
          end
        end
      end
    end

  end
end
