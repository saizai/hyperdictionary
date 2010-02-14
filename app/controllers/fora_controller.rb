class ForaController < ApplicationController
  before_filter :get_context
  
  def index
    @fora = @context.fora.order("name").includes(:last_discussion, :last_message)
    
    respond_to do |format|
      format.js   { render :layout => false }
      format.html # index.html.erb
      format.xml  { render :xml => @fora }      
    end
  end
  
#  def show
#    
#  end
  
  protected
  
  def get_context
    @context = Page.find(params[:page_id]) if params[:page_id]
  end
end
