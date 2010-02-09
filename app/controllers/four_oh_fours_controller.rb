class FourOhFoursController < ApplicationController
  permit 'site_admin', :only => 'index'
  
  def log
    FourOhFour.add_request(request.url,
                           request.env['HTTP_REFERER'] || '')
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404.html" ,
                           :status => "404 Not Found" }
      format.all { render :nothing => true,
                           :status => "404 Not Found" }
    end
  end
  
  def index
    @fours = FourOhFour.paginate :all,
       :per_page => 50, :page => params[:page],
       :order => 'id desc'
  end
end

