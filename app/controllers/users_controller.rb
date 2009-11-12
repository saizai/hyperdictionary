class UsersController < ApplicationController
  permit 'site_admin', :only => :index
  permit 'guest', :only => [:new, :create, :rpx_login], :permission_denied_message => 'Please log out first.'
  before_filter :login_required, :only => [:rpx_add, :change_password]
  
  def index
    @users = User.active.paginate :all, :per_page => 50, :page => params[:page]
  end
  
  def show
    @user = User.find(params[:id], :include => [:public_contacts, :identities]) # _by_login
    if permit? 'site_admin'
      @multis = @user.multis
      @ips = @user.ips_with_names
      @identities = @user.identities
    else
      @identities = @user.identities.public
    end
    @contacts = @user.public_contacts
    @friends = @user.friends
    @fans_of = @user.fans_of
    @fans = @user.fans
    @current_user_friends = current_user.friends_and_fans_of if logged_in?
    @can_add_friend = (logged_in? and current_user != @user and !@current_user_friends.include?(@user))
    @badges = @user.badges
  end
  
  def edit
    @user = User.find(params[:id], :include => [:public_contacts, :identities]) # _by_login
    if permit? 'site_admin or (self of user)'
      if permit? 'site_admin'
        @multis = @user.multis
        @ips = @user.ips_with_names
      end
      @assets = @user.assets.original
      @contacts = @user.contacts
      @roles = @user.roles
      @preferences = @user.preferences
      @emails = @user.contacts.emails.map(&:data)
      @identities = @user.identities
      @friends = @user.friends
      @fans_of = @user.fans_of
      @fans = @user.fans
      @current_user_friends = current_user.friends_and_fans_of
      @can_add_friend = (current_user != @user and !@current_user_friends.include?(@user))
      @badges = @user.badges
    else
      flash[:error] = 'You do not have permission to view that page.'
      redirect_to @user
    end
  end
  
  def set_user_name
    @user = User.find(params[:id])
    permit 'site_admin or (self of user)' do
      @user.update_attribute(:name, params[:value])
      render :text => CGI::escapeHTML(@user.name)
    end
  end
  
  # Note: Users can set any preferences on themselves. Do not use this for anything that needs to be secure; that's what Roles are for.
  def set_preference
    @user = User.find(params[:id])
    permit 'site_admin or (self of user)' do
      preferred = if params[:preferred_type]
        preferred_class = params[:preferred_type].classify.constantize
        params[:preferred_id] ? preferred_class.find(params[:preferred_id]) : preferred_class
      else
        nil
      end
      @user.set_preference params[:preference], params[:value], preferred || @user
      
      render :partial => '/users/preferences', :locals => {:user => @user}
    end
  end
  
  # Technically, this breaks REST and is un-DRY, because it handles both user and session creation. Oh well, APIs.
  def rpx_login
    @user = User.find_or_initialize_with_rpx(params[:token])
    if @user.nil?
      flash[:error] = "Login token expired. Please try again."
      redirect_back_or_default('/login')
    elsif @user.new_record? # first pass of signing up w/ a new identity; the next one will call #create
      session[:rpx_user] = @user # stash it in the session 'cause we're just going to have to get it again in a sec, and it might expire in the meantime
      render :action => "new_openid"
    elsif @user.active?
      # Note: this is duplicated @ sessions_controller#create. Maybe refactorable, but not worth it.
      @user.sessions.stale.destroy_all 
      logout_killing_session!
      self.current_user = @user
      Event.event! current_user, 'log in'
      @user.update_time_in_app!
      flash[:notice] = "Logged in successfully"
      redirect_back_or_default('/')#@user)
    else
      flash[:error] = "Your account is #{@user.state}. Please email an administrator to correct this."
      redirect_back_or_default('/')
    end
  end
  
  def rpx_add
    new_identity = current_user.identities.find_or_initialize_with_rpx(params[:token])
    new_identity.save
    
    redirect_back_or_default user_path(current_user)
  end
  
  # render new.rhtml
  def new
    @user = User.new
    @recaptcha = false
  end
 
  def create
    logout_keeping_session!
    email = params[:user].delete(:email)
    
    if params[:rpx_token]
      @user = session[:rpx_user] || User.find_or_initialize_with_rpx(params[:rpx_token])
      if @user.nil? # RPX returned nil. Probably the user took too long and token expired.
        flash[:error] = "There was a problem authenticating your external account. Most likely you took too long to complete the process and the token expired. Please try again."
        redirect_to :action => 'new' and return
      end
      @user.attributes = params[:user]
    else
      @user = User.new(params[:user])
    end
    
    success = if @user and @user.valid?
      User.transaction do
        @user.activate!
        contact = @user.contacts.build(:contact_type_id => ContactType.find_by_name('email').id, :data => email)
        contact.register!
      end
    end
    
    if success and @user.errors.empty?
      flash[:notice] = "Thanks for signing up!"
      session.delete :rpx_user
      self.current_user = @user
      redirect_back_or_default(@user)
    elsif !@user.identities.blank?
      render :action => 'new_openid'
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin."
      render :action => 'new'
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    if (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to '/login'
    elsif params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end

  
  # For changing when logged in
  def change_password
    @user = current_user
    @old_password = params[:old_password]
    @user.password, @user.password_confirmation = params[:user][:password], params[:user][:password_confirmation]
    if @user.crypted_password? and !@user.authenticated? @old_password
      @user.errors.add_to_base "Current password wrong, please try again."
    else
      @user.reset_password!
      if @user.save
        flash[:notice] = "Password changed."
      end
    end
    render :action => 'show'
  end
  
  # Just shows the 'enter your email to get the link' form
  def forgot_password    
    if request.post? # otherwise just show it
      if user = User.find_by_email(params[:email])
        user.forgot_password!
        user.save
        flash[:notice] = "A password reset link has been sent to your email address."
        redirect_to root_path and return
      else
        flash[:notice] = "A password reset link was not sent, you may have enetered an invalid email address."
      end
    end
  end
  
  def reset_password
    logout_keeping_session!
    @code = params[:password_reset_code]
    @user = User.find_by_password_reset_code(@code) unless @code.blank?
    if @user
      if request.put?
        @user.password, @user.password_confirmation = params[:user][:password], params[:user][:password_confirmation]
        @user.reset_password!
        if @user.save # else fall through to show w/ errors
          flash[:notice] = "Signup complete! Please sign in to continue."
          redirect_to '/login'
          return
        end
      end # else we show the prompt for new password
    elsif @code.blank?
      flash[:error] = "The password reset code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else 
      flash[:error]  = "We couldn't find a user with that password reset code -- check your email? Or maybe you've already used it -- try signing in."
      redirect_back_or_default('/')
    end
  end
end
