class BadgesController < ApplicationController
  def index
    @badges = Badge.public.all(:include => :badge_set)
    @user_badge_ids = current_user.badge_ids if logged_in?
  end
  
end
