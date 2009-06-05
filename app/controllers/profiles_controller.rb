class ProfilesController < ApplicationController
  permit 'site_admin', :only => :destroy
  before_filter :login_required, :only => [:new, :create, :edit, :update]
  
  # GET /profiles
  # GET /profiles.xml
  def index
    @profiles = Profile.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @profiles }
    end
  end

  # GET /profiles/1
  # GET /profiles/1.xml
  def show
#    if params[:version]
#      @profile = Profile.find(params[:id]).versions.find_by_lock_version(params[:version])
#    else
      @profile = Profile.find(params[:id], :include => [:assets, {:comments => :creator}])
#    end
    @title = @profile.name
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @profile }
    end
  end
  
  # GET /profiles/new
  # GET /profiles/new.xml
  def new
    @profile = Profile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @profile }
    end
  end

  # GET /profiles/1/edit
  def edit
    @profile = Profile.find(params[:id])
    @owner = @profile.owner
    permit 'site_admin or (self of owner) or (editor of profile)'
  end
  
  def subscribe
    @profile = Profile.find(params[:id])
    if subscribed = current_user.has_role?('subscriber', @profile)
      current_user.has_no_role 'subscriber', @profile
    else
      current_user.has_role 'subscriber', @profile
    end
    
    respond_to do |format|
      format.js   { render :partial => '/profiles/subscribe', :locals => {:profile => @profile}  }
      format.html {
        flash[:notice] = "Successfully #{ 'un' if subscribed }subscribed."
        redirect_to @profile
      }
      format.xml  { head :ok }
    end
  end
  
  def change_role
    @profile = Profile.find(params[:id])
    permit 'site_admin or (owner of profile)' do
      begin
        login = params[:login].try :downcase
        @user = ((login.blank? or login == 'anonymous') ? AnonUser : User.find(login))
        Profile::ROLES.each do |old_role|
          @user.has_no_role old_role, @profile
        end
        @user.has_role params[:role], @profile unless params[:role].blank?
        
        respond_to do |format|
          format.js { 
            render :update do |page|
              page.replace "profile_roles_container_#{@profile.id}", :partial => '/profiles/roles', :locals => {:profile => @profile, :shown => true}
            end
          }
          format.html { 
            flash[:notice] = 'Roles successfully updated.'
            redirect_to @profile
          }
          format.xml { head :ok }
        end
        
      rescue ActiveRecord::RecordNotFound
        error_text = "User #{params[:login]} not found."
        respond_to do |format|
          format.js { 
            render :update do |page|
              page.alert error_text
            end
          }
          format.html { 
            flash[:error] = error_text
            redirect_to @profile
          }
        end
      end
    end
  end

  # POST /profiles
  # POST /profiles.xml
  def create
    @profile = Profile.new(params[:profile])
    
    respond_to do |format|
      if @profile.save
        flash[:notice] = 'Profile was successfully created.'
        format.html { redirect_to(@profile) }
        format.xml  { render :xml => @profile, :status => :created, :location => @profile }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /profiles/1
  # PUT /profiles/1.xml
  def update
    @profile = Profile.find(params[:id])
    @owner = @profile.owner
    permit 'site_admin or (self of owner) or (editor of profile)' do
      respond_to do |format|
        if @profile.update_attributes(params[:profile])
          flash[:notice] = 'Profile was successfully updated.'
          format.html { redirect_to(@profile) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /profiles/1
  # DELETE /profiles/1.xml
  def destroy
    @profile = Profile.find(params[:id])
    permit 'site_admin or (self of owner)' do
      @profile.destroy
  
      respond_to do |format|
        format.html { redirect_to(profiles_url) }
        format.xml  { head :ok }
      end
    end
  end
end
