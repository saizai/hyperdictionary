class UsersController < ApplicationController
  permit 'admin', :only => :index
  permit 'guest', :only => [:new, :create, :rpx_login], :permission_denied_message => 'Please log out first.'
  
  def index
    @users = User.active.paginate :all, :per_page => 50, :page => params[:page]
  end

  def show   
    @user = User.find(params[:id]) # _by_login
    permit 'admin or (self of user)'
  end
  
  # Note: Users can set any preferences on themselves. Do not use this for anything that needs to be secure; that's what Roles are for.
  def set_preference
    @user = User.find(params[:id])
    permit 'admin or (self of user)'
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
      redirect_back_or_default('/')
    else
      flash[:error] = "Your account is #{@user.state}. Please email an administrator to correct this."
      redirect_back_or_default('/')        
    end
  end
  
  # For changing when logged in
  def change_password
    @user = current_user
    @old_password = params[:old_password]
    @user.password, @user.password_confirmation = params[:user][:password], params[:user][:password_confirmation]
    if !@user.authenticated? @old_password
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
      # We actually don't permit user to set identity_url directly; if they try, it's suspicious enough to raise a red flag and hard stop
      raise "Submitted URL doesn't match token" unless @user.identity_url == params[:user][:identity_url]
    else
      @user = User.new(params[:user])
    end
    
    success = if @user and @user.valid?
      if @user.verified_email == @user.email and !@user.email.blank?
        @user.activate!
      else
        @user.register!
      end
      
      # NOTE: Because this is effectively a single external db, we don't want to tie it to bad IDs.
      # Therefore you need a separate RPX API key for each separate database, or at least promise not to map.
      if Rails.env.production? or Rails.env.development?
        RPXNow.map @user.identity_url, @user.id if @user.identity_url
      end
      true
    end
    
    if success and @user.errors.empty?
      flash[:notice] = "Thanks for signing up!"
      flash[:notice] += " We're sending you an email with your activation code." if @user.pending?
      redirect_back_or_default('/')
    elsif @user.identity_url?
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

  
  # There's no page here to update or destroy a user.  If you add those, be
  # smart -- make sure you check that the visitor is authorized to do so, that they
  # supply their old password along with a new one to update it, etc.


end
