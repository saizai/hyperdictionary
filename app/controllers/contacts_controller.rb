class ContactsController < ApplicationController
  before_filter :login_required, :only => [:create, :update]
  before_filter :find_user
  
  def index
    @contacts = @user.contacts.paginate :all, :per_page => 50, :page => params[:page]
  end
  
  def create
    @contact = @user.contacts.new(params[:contact])
    
    permit 'site_admin or (self of user)' do
      success = @contact.register! if @contact and @contact.valid?
      if success and @contact.errors.empty?
        respond_to do |format|
          format.js   { render :partial => 'contact', :locals => {:contact => @contact}  }
          format.html {
            flash[:notice] = " We're sending you an email with your activation code." 
            redirect_back_or_default @user
          }
          format.xml { head :ok }
        end
      else
# TODO: handle error
      end
    end
  end
  
  def verify
    @contact = @user.contacts.find(params[:id])
    
    permit 'site_admin or (self of user)' do
      @contact.register!
      respond_to do |format|
        format.js   { render :partial => 'contact', :locals => {:contact => @contact}  }
        format.html {
          flash[:notice] = " We're sending you an email with your activation code." 
          redirect_back_or_default @user
        }
        format.xml { head :ok }
      end
# TODO: handle error
    end
  end
  
  def screen
    @contact = @user.contacts.find(params[:id])
    permit 'site_admin or (self of user)' do
      @contact.toggle :public
      
      respond_to do |format|
        if @contact.save
          format.js   { render :partial => 'contact'  }
          format.html {
            flash[:notice] = 'Contact was successfully screened.'
            redirect_to @user 
          }
          format.xml  { head :ok }
        else
          format.html { 
            flash[:notice] = 'Error screening contact.'
            redirect_to @user
          }
          format.xml  { render :xml => @contact.errors, :status => :unprocessable_entity }
        end
      end
    end
  end
  
  def suspend
    @contact = @user.contacts.find(params[:id])
    permit 'site_admin or (self of user)' do
      @contact.suspended? ? @contact.unsuspend! : @contact.suspend!
      
      respond_to do |format|
        if @contact.save
          format.js   { render :partial => 'contact'  }
          format.html {
            flash[:notice] = "Contact was successfully #{'un' if !@contact.suspended?}suspended."
            redirect_to @user 
          }
          format.xml  { head :ok }
        else
          format.html { 
            flash[:notice] = 'Error suspending contact.'
            redirect_to @user
          }
          format.xml  { render :xml => @contact.errors, :status => :unprocessable_entity }
        end
      end
    end
  end
  
  def activate
    @contact = @user.contacts.find(params[:id])
    @contact.activation_code_entered = params[:activation_code]
    @contact.activate!
    
    if @contact.active?
      flash[:notice] = "Contact verified! Thank you."
    elsif params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
    end
    redirect_to @user
  end
  
  protected
  
  def find_user
    @user = User.find(params[:user_id])
  end

end
