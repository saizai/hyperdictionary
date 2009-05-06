class Admin::MainController < ApplicationController
  permit 'admin'
  
  def index
    @users = User.count
    @exceptions = LoggedException.count
    @fours = FourOhFour.count
  end
  
  def preferences
    @preferences = Preference.find(:all, :group => :name, :select => 'name, count(*) as count')
  end
end
