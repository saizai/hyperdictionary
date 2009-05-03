class Admin::MainController < ApplicationController
  permit 'admin'
  
  def index
    @users = User.count
    @exceptions = LoggedException.count
    @fours = FourOhFour.count
  end
end
