class ParticipationsController < ApplicationController
  before_filter :get_context
  
  def create
    current_participation = @discussion.participations.where(:user_id => current_user.id).first
    
    permit !current_participation.nil? do
      participants = User.find(params[:participation][:users].split(',').map(&:strip)) 
      @participations = participants.map{|p| @discussion.participations.new :user_id => p.id}
      
      respond_to do |format|
        if @participations.map(&:save) # TODO: use import here
          format.js   { render :partial => '/users/list', :locals => {:users => @discussion.participants, :badges => false}  }
          format.html {
            flash[:notice] = "#{partiicpation.user.login} was successfully added to this discussion."
            redirect_to discussion
          }
          format.xml  { head :ok }
        else
          format.js   { render :inline => @participation.errors.each_full{|error| error }, :status => :unprocessable_entity }
          format.html { render :action => "new" }
          format.xml  { render :xml => @discussion.errors, :status => :unprocessable_entity }
        end
      end
    end
  end
  
  private
  
  def get_context
    @discussion = Discussion.find(params[:discussion_id]) if params[:discussion_id]
    @user = User.find(params[:user_id]) if params[:user_id]
  end
end
