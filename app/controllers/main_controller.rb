class MainController < ApplicationController
  before_filter :login_required, :only => :home
  
  def index
  end

  def home
  end

  def about
  end

end
