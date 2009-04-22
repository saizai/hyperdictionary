class Admin::MainController < ApplicationController
  before_filter :login_required
  permit 'admin'
  
  def index
    @users = User.count
    @exceptions = LoggedException.count
    @fours = FourOhFour.count
  end
end
