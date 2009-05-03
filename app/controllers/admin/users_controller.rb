class Admin::UsersController < ApplicationController
	before_filter :login_required
  permit 'admin'

  before_filter :find_user, :except => :index
#  after_filter :refresh_user, :except => :index
  
  def index
    @users = User.paginate :all, :per_page => 50, :page => params[:page]
  end
  
  def activate
    @user.activate!
    refresh_user
  end

  def suspend
    @user.suspend! 
    refresh_user
  end

  def unsuspend
    @user.unsuspend! 
    refresh_user
  end
  
  def destroy
    @user.delete!
    refresh_user
  end

  def purge
    @user.destroy
    refresh_user
  end
  
  def remove_role
    role = Role.find(params[:role_id])
    @user.has_no_role role.name, role.authorizable
    refresh_user
  end
  
  def add_role
    authorizable = params[:class].constantize.find(params[:class_id]) if !params[:class].blank?
    @user.has_role params[:name], authorizable
    refresh_user
  end
  
  def reset
    @user.forgot_password!
    @user.save
    refresh_user
  end
  
  def map
    RPXNow.map params[:url], @user.id
    refresh_user
  end
  
  def unmap
    RPXNow.unmap params[:url], @user.id 
    refresh_user
  end
  
  protected
  
  def find_user
    @user = User.find(params[:id])
    @models = ActiveRecord::Base.send(:subclasses).map(&:to_s).reject{|x| x =~ /:/}.sort
  end
  
  def refresh_user
    render :update do |page| # only for this person
      page.replace "user_#{@user.id}", :partial => '/admin/users/user'
      page.visual_effect :highlight, "user_#{@user.id}"
    end 
  end
end

