class Admin::UsersController < ApplicationController
  permit 'site_admin', :except => :spoof

  before_filter :find_user, :except => [:index, :spoof]
  after_filter :refresh_user, :except => [:index, :spoof, :same_ip]
  
  def index
    @users = User.paginate :all, :per_page => 50, :page => params[:page], :include => [{:roles_users => :role}, :identities, :page]
    @anon_roles = AnonUser.roles
  end
  
  # Pretend to be a user for all purposes EXCEPT for spoofing, session, and logout
  def spoof
    permit logged_in_as_admin?(true) do # Note that permit is acting as the spoofed user, so we need to undercut it
      id = params[:id].try :downcase
      begin
        unless id == current_user(true).login
          new_user = (id == 'anonymous' || id.blank? ? AnonUser : User.find(id))
          session[:spoofed_user] = new_user.id # convert login to ID #
          session[:spoofing_user?] = params[:spoof_user?]
          Event.event! current_user(true), (params[:spoof_user?] ? 'started' : 'stopped') + ' spoofing', new_user
        end
        # render :partial => '/admin/users/spoof'
        render :update do |page|
          page.reload
        end
      rescue ActiveRecord::RecordNotFound
        render :inline => "#{params[:id]} not found", :status => 404
      end
    end
  end
  
  def same_ip
    # TODO: handle non-js usage
    @users = @user.users_on_same_ip
    render :partial => '/users/list', :locals => {:users => @users}, :status => :ok
  end
  
  def activate
    @user.activate!
  end

  def suspend
    @user.suspend! 
  end

  def unsuspend
    @user.unsuspend! 
  end
  
  def destroy
    @user.delete! # Goes through AASM
  end

  def purge
    @user.delete!
    @user.destroy # Goes through acts_as_paranoid (use @user.destroy! to really actually delete the record)
  end
  
  def remove_role
    role = Role.find(params[:role_id])
    @user.has_no_role role.name, role.authorizable
  end
  
  def add_role
    authorizable = params[:class].constantize.find(params[:class_id]) if !params[:class].blank?
    @user.has_role params[:name], authorizable
  end
  
  def reset
    @user.forgot_password!
    @user.save
  end
  
  def map
    @user.identities.build :url => params[:url]
    @user.save
  end
  
  def unmap
    @user.identities.find(params[:identity_id]).destroy
  end
  
  protected
  
  def find_user
    @user = (params[:id] == 'AnonUser' ? AnonUser : User.find(params[:id]))
    @models = ActiveRecord::Base.send(:subclasses).map(&:to_s).reject{|x| x =~ /:/}.sort
  end
  
  def refresh_user
    if @user == AnonUser
      render :update do |page|
        page.replace_html 'anon_roles', :partial => 'user_roles', :locals => {:user => AnonUser}
        page.visual_effect :highlight, 'anon_roles'
      end
    else
      render :update do |page| # only for this person
        page.replace "user_#{@user.id}", :partial => '/admin/users/user'
        page.visual_effect :highlight, "user_#{@user.id}"
      end
    end
  end
end

