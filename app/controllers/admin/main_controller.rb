class Admin::MainController < ApplicationController
  permit 'site_admin'
  
  def index
    @users = User.count
    @exceptions = LoggedException.count
    @fours = FourOhFour.count
  end
  
  def preferences
    @preferences = Preference.paginate(:all, :per_page => 50, :page => params[:page], 
      :group => 'name, value', :order => 'name, value',
      :select => 'name, value, count(*) as count').inject({}){|i, p| 
        i[p.name] ||= {}
        i[p.name][p.value] = p.count
        i  }
  end
  
  # Activate admin privileges
  def admin_mode
    permit logged_in_as_admin?(true) do # Note that permit is acting as the spoofed user, so we need to undercut it
      id = params[:id].try :downcase
      session[:admin_mode] = params[:admin_mode]
      render :update do |page|
        page.reload
      end
    end
  end
  
end
