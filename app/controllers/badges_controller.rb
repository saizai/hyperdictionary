class BadgesController < ApplicationController
  def index
    @badges = Badge.public.all(:include => :badge_set)
    @user_badges = current_user.badges if logged_in?
  end

end
