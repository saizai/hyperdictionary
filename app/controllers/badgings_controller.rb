class BadgingsController < ApplicationController
  before_filter :find_user
  
  def create
    @badge = Badge.find(params[:badging][:badge_id])
    
    permit 'site_admin' do
      if @user.badgings.grant! @badge.badge_set_id, @badge.level
        respond_to do |format|
          format.js   { render :partial => '/badges/badge', :locals => {:badge => @badge}  }
          format.html {
            flash[:notice] = "Badging added." 
            redirect_back_or_default @user
          }
          format.xml { head :ok }
        end
      else
# TODO: handle error
        head :unprocessable_entity
      end
    end
  end
  
  protected
  
  def find_user
    @user = User.find(params[:user_id])
  end
end