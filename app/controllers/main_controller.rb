class MainController < ApplicationController
  def index
    redirect_to home_path if logged_in?
  end

  def home
    redirect_to login_path unless logged_in?
  end

  def about
  end

end
