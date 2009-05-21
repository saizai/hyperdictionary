class UsersController < ApplicationController
  permit 'site_admin', :only => :index
  permit 'guest', :only => [:new, :create, :rpx_login], :permission_denied_message => 'Please log out first.'
  before_filter :login_required, :only => [:rpx_add, :change_password]
  
  def index
    @users = User.active.paginate :all, :per_page => 50, :page => params[:page]
  end

  def show   
    @user = User.find(params[:id], :include => [:roles, :preferences, :assets]) # _by_login
    permit 'site_admin or (self of user)'
    
    @assets = @user.assets.original
  end
  
  # Note: Users can set any preferences on themselves. Do not use this for anything that needs to be secure; that's what Roles are for.
  def set_preference
    @user = User.find(params[:id])
    permit 'site_admin or (self of user)'
    preferred = if params[:preferred_type]
      preferred_class = params[:preferred_type].classify.constantize
      params[:preferred_id] ? preferred_class.find(params[:preferred_id]) : preferred_class
    else
      nil
    end
    @user.set_preference params[:preference], params[:value], preferred || @user
    
    render :partial => '/users/preferences', :locals => {:user => @user}
  end
  
  # Technically, this breaks REST and is un-DRY, because it handles both user and session creation. Oh well, APIs.
  def rpx_login
    logout_keeping_session!
    @user = User.find_or_initialize_with_rpx(params[:token])
    if @user.new_record?
      render :action => "new_openid"
    elsif @user.pending?
      flash[:error] = "Please click the URL in your email from us to activate your account."
      UserMailer.deliver_activation(@user)
      redirect_back_or_default('/')
    elsif @user.active?
      self.current_user = @user
      flash[:notice] = "Logged in successfully"
      redirect_back_or_default('/home')
    else
      flash[:error] = "Your account is #{@user.state}. Please email an administrator to correct this."
      redirect_back_or_default('/')
    end
  end
  
  def rpx_add
    current_user.identities << Identity.find_or_initialize_with_rpx(params[:token])
    current_user.save
    
    redirect_back_or_default user_path(current_user)
  end
  
  # render new.rhtml
  def new
    @user = User.new
    @recaptcha = false
  end
 
  def create
    logout_keeping_session!
    if params[:rpx_token]
      @user = User.find_or_initialize_with_rpx params[:rpx_token]
      if @user.nil? # RPX returned nil. Probably the user took too long and token expired.
        flash[:error] = "There was a problem authenticating your external account. Most likely you took too long to complete the process and the token expired. Please try again."
        redirect_to :action => 'new' and return
      end
      @user.attributes = params[:user]
    else
      @user = User.new(params[:user])
    end
    
    success = if @user and @user.valid?
      if @user.email_verified_by_open_id?
        @user.activate!
      else
        @user.register!
      end
    end
    
    if success and @user.errors.empty?
      flash[:notice] = "Thanks for signing up!"
      if @user.pending?
        flash[:notice] += " We're sending you an email with your activation code." 
      else
        self.current_user = @user
      end
      redirect_back_or_default('/home')
    elsif !@user.identities.blank?
      render :action => 'new_openid'
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
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
