class EventsController < ApplicationController
  before_filter :get_eventable
  
  def index
    page = (params[:page] || 1)
    
    @aggregated_events = if !@eventable
      EventEventable.recent(20, page).aggregated_events
    elsif @eventable.is_a?(Page) and @eventable.namespace == 'User' # special case - user pages show their user's events too
      EventEventable.with_eventables([@eventable, @eventable.owner]).recent(20, page).aggregated_events
    else
      @eventable.event_eventables.recent(20,  page).aggregated_events
    end
    
    respond_to do |format|
      format.js   { render :layout => false }
      format.html # index.html.erb
      format.xml  { render :xml => @aggregated_events }
    end
  end
  
  protected
  
  def get_eventable
    @eventable = params[:eventable_type].constantize.find(params[:eventable_id]) if params[:eventable_type] and params[:eventable_id]
  end
end
