class MessagesController < ApplicationController
  before_filter :get_discussion
  
#   GET /messages
#   GET /messages.xml
  def index
    @messages = @discussion.messages.by_index.paginate :page => params[:page], :include => [:creator, :updater] # :context
    # FIXME: filter @messages by visibility here not in view (it'd leak to xml)
    
    respond_to do |format|
      format.js   { render :layout => false }
      format.html # index.html.erb
      format.xml  { render :xml => @messages }      
    end
  end
  
  # GET /messages/1
  # GET /messages/1.xml
#  def show
#    @message = Message.find(params[:id])
#
#    respond_to do |format|
#      format.html # show.html.erb
#      format.xml  { render :xml => @message }
#    end
#  end

  # GET /messages/new
  # GET /messages/new.xml
#  def new
#    @message = Message.new
#
#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => @message }
#    end
#  end

  # GET /messages/1/edit
#  def edit
#    @message = Message.find(params[:id])
#    @messager = @message.creator
#    permit 'admin or (self of messager)'
#  end
  
  def render_markdown
    render :inline => "<%= markdown(params[:text]) %>"
  end
  
  def moderate
    @message = Message.find(params[:id])
    
    permit @message.discussion.moderated_by?(current_user) do
      @message.toggle :moderated
      
      respond_to do |format|
        if @message.save
          format.js   { render :partial => 'message'  }
          format.html {
            flash[:notice] = 'Message was successfully moderated.'
            redirect_to message.discussion 
          }
          format.xml  { head :ok }
        else
          format.html { 
            flash[:notice] = 'Error moderating message.'
            redirect_to message.discussion 
          }
          format.xml  { render :xml => @message.errors, :status => :unprocessable_entity }
        end
      end
    end
  end
  
  def screen
    @message = Message.find(params[:id])
    
    permit @message.discussion.member_by?(current_user) do
      @message.toggle :private
      
      respond_to do |format|
        if @message.save
          format.js   { render :partial => 'message'  }
          format.html {
            flash[:notice] = 'Message was successfully screened.'
            redirect_to message.discussion 
          }
          format.xml  { head :ok }
        else
          format.html { 
            flash[:notice] = 'Error screening message.'
            redirect_to message.discussion 
          }
          format.xml  { render :xml => @message.errors, :status => :unprocessable_entity }
        end
      end
    end
  end
  
  # POST /messages
  # POST /messages.xml
  def create
    @message = @discussion.messages.new(params[:message])
    
    respond_to do |format|
      if @message.save and @discussion.mark_read_by!(current_user)
        format.js   { render :partial => 'message'  }
        format.html {
          flash[:notice] = 'Message was successfully created.'
          redirect_to message.discussion 
        }
        format.xml  { render :xml => @message, :status => :created, :location => @message }
      else
        format.js   { render :inline => @message.errors.each_full{|error| error }, :status => :unprocessable_entity }
        format.html { render :action => "new" }
        format.xml  { render :xml => @message.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /messages/1
  # PUT /messages/1.xml
#  def update
#    @message = Message.find(params[:id])
#    @messager = @message.creator
#    permit 'site_admin or (self of messager)' do
#
#      respond_to do |format|
#        if @message.update_attributes(params[:message])
#          flash[:notice] = 'Message was successfully updated.'
#          format.html { redirect_to(@message) }
#          format.xml  { head :ok }
#        else
#          format.html { render :action => "edit" }
#          format.xml  { render :xml => @message.errors, :status => :unprocessable_entity }
#        end
#      end
#    end
#  end

  # DELETE /messages/1
  # DELETE /messages/1.xml
  def destroy
    @message = Message.find(params[:id])
    permit @message.discussion.owned_by?(current_user) do
      @message.destroy
      
      respond_to do |format|
        format.html { redirect_to(messages_url) }
        format.xml  { head :ok }
      end
    end
  end
  
  protected
  
  def get_discussion
    @discussion ||= Discussion.find(params[:discussion_id]) if params[:discussion_id]
    # FIXME: is there a better way to find out what the parent resource is?
    if params[:page_id]
      @context = page = Page.find(params[:page_id])
      @discussion ||= page.wall_discussion || page.build_wall_discussion(:name => page.name + ' wall') # FIXME: this should be moved into a model hook somewhere
      @interface = 'wall'
    elsif params[:forum_id]
      @interface = 'forum'
    elsif params[:user_id]
      @interface = 'inbox'
    end
  end
end
