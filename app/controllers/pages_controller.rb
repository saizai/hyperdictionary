class PagesController < ApplicationController
  permit 'site_admin', :only => :destroy
  before_filter :login_required, :only => [:new, :create, :edit, :update]
  
  # GET /pages
  # GET /pages.xml
  def index
    @pages = Page.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pages }
    end
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
# TODO: add interface to show revisions (and hopefully diffs?)
#    if params[:version]
#      @page = Page.find(params[:id]).versions.find_by_lock_version(params[:version])
#     ...
    
    @page = Page.find(params[:id], :include => :assets)
    
    if @page.namespace = 'User' and !request.xhr? # only load user pages within users
      redirect_to user_path @page.owner
      return
    end
    
    permit @page.read_by?(current_user) do
      @title = @page.name
      
      respond_to do |format|
        format.js   {render :layout => false}
        format.html # show.html.erb
        format.xml  { render :xml => @page }
      end
    end
  end
  
  # GET /pages/new
  # GET /pages/new.xml
  def new
    @page = Page.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /pages/1/edit
  def edit
    @page = Page.find(params[:id])
    permit @page.edited_by?(current_user)
  end
  
  def subscribe
    @page = Page.find(params[:id])
    permit @page.read_by?(current_user) or current_user.is_subscriber_of?(@page) do
      if subscribed = current_user.has_role?('subscriber', @page)
        current_user.has_no_role 'subscriber', @page
      else
        current_user.has_role 'subscriber', @page
      end
      
      respond_to do |format|
        format.js   { render :partial => '/pages/subscribe', :locals => {:page => @page}  }
        format.html {
          flash[:notice] = "Successfully #{ 'un' if subscribed }subscribed."
          redirect_to @page
        }
        format.xml  { head :ok }
      end
    end
  end
  
  def change_role
    @page = Page.find(params[:id])
    permit @page.owned_by?(current_user) do
      begin
        login = params[:login].try :downcase
        @user = ((login.blank? or login == 'anonymous') ? AnonUser : User.find(login))
        Page::ROLES.each do |old_role|
          @user.has_no_role old_role, @page
        end
        @user.has_role params[:role], @page unless params[:role].blank?
        
        respond_to do |format|
          format.js { 
            render :update do |page|
              page.replace "page_roles_container_#{@page.id}", :partial => '/pages/roles', :locals => {:page => @page, :shown => true}
            end
          }
          format.html { 
            flash[:notice] = 'Roles successfully updated.'
            redirect_to @page
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
            redirect_to @page
          }
        end
      end
    end
  end

  # POST /pages
  # POST /pages.xml
  def create
    @page = Page.new(params[:page])
    
    respond_to do |format|
      if @page.save
        flash[:notice] = 'Page was successfully created.'
        format.html { redirect_to(@page) }
        format.xml  { render :xml => @page, :status => :created, :location => @page }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.xml
  def update
    @page = Page.find(params[:id])
    permit @page.edited_by?(current_user) do
      respond_to do |format|
        if @page.update_attributes(params[:page])
          flash[:notice] = 'Page was successfully updated.'
          format.html { redirect_to(@page) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.xml
  def destroy
    @page = Page.find(params[:id])
    permit @page.owned_by?(current_user) do
      @page.destroy
  
      respond_to do |format|
        format.html { redirect_to(pages_url) }
        format.xml  { head :ok }
      end
    end
  end
end
