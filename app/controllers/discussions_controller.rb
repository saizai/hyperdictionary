class DiscussionsController < ApplicationController
  before_filter :get_context
  
  def index
    @discussions = (@context.is_a?(User) ? @context.inbox_discussions : 
                      @context.discussions).paginate :page => params[:page], :order => "updated_at DESC", :include => [:context, :creator, :updater, :last_message] #, :participants]
    discussion_ids = @discussions.map(&:id)
    
    if logged_in? # fetch current user's participation object on each discussion
      # TODO: put this into an :include-able has_one ? would require user injection into model and some sort of lambda, though
      participations = current_user.participations.find(:all, :conditions => ["participations.discussion_id IN (?)", discussion_ids]).inject({}){|m,x| m[x.discussion_id] = x; m }
      @discussions.map!{|d| d.participation = participations[d.id]; d}
    end
    
    # TODO: display first unread messages in snippets instead of last_message?
    
    if @context.is_a? User
      respond_to do |format|
        format.js { render :action => :inbox, :layout => false }
        format.html { render :action => :inbox }
        format.xml { render :xml => @discussions }
      end
    else
      respond_to do |format|
        format.js   { render :layout => false }
        format.html # index.html.erb
        format.xml  { render :xml => @discussions }      
      end
    end
  end
  
  def show
    @discussion = @context.discussions.find(params[:id])
    @discussion.mark_read_by!(current_user) if logged_in?
    
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @discussion }
    end    
  end
  
  def new
    @discussion = @context.discussions.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @discussion }
    end
  end
  
  def create
    # TODO: Check permissions first?
    @discussion = @context.discussions.new(params[:discussion])
    @discussion.messages.map {|m| m.context = @context }
    
    respond_to do |format|
      if @discussion.save
        format.js   { render :partial => 'discussion_slim', :locals => {:discussion => @discussion}  }
        format.html {
          flash[:notice] = 'Discussion was successfully created.'
          redirect_to discussion.context 
        }
        format.xml  { render :xml => @discussion, :status => :created, :location => @discussion }
      else
        format.js   { render :inline => @discussion.errors.each_full{|error| error }, :status => :unprocessable_entity }
        format.html { render :action => "new" }
        format.xml  { render :xml => @discussion.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  protected
  
  def get_context
    # FIXME: is there a better way to find out what the parent resource is?
    @context = User.find(params[:discussion][:to_user]) if params[:discussion] and params[:discussion][:to_user]
    @context ||= params[:context_type].constantize.find(params[:context_id]) if params[:context_type] and params[:context_id]
    @context ||= Page.find(params[:page_id]) if params[:page_id]
    @context ||= User.find(params[:user_id]) if params[:user_id]
  end
 end
