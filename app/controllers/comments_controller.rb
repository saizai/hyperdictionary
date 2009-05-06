class CommentsController < ApplicationController
  permit 'admin', :only => :moderate
  
  # GET /comments
  # GET /comments.xml
  def index
    @comments = Comment.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @comments }
    end
  end

  # GET /comments/1
  # GET /comments/1.xml
  def show
    @comment = Comment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  # GET /comments/new
  # GET /comments/new.xml
  def new
    @comment = Comment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  # GET /comments/1/edit
  def edit
    @comment = Comment.find(params[:id])
  end
  
  def moderate
    @comment = Comment.find(params[:id])
    @comment.toggle :moderated
    
    respond_to do |format|
      if @comment.save
        format.js   { render :partial => 'comment'  }
        format.html {
          flash[:notice] = 'Comment was successfully moderated.'
          redirect_to comment.commentable 
        }
        format.xml  { head :ok }
      else
        format.html { 
          flash[:notice] = 'Error moderating comment.'
          redirect_to comment.commentable 
        }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end
    
  def screen
    @comment = Comment.find(params[:id])
    @commenter = @comment.creator
    @owner = @comment.commentable.try :user
    permit 'admin or (self of commenter) or (self of owner)'
    
    @comment.toggle :private
    
    respond_to do |format|
      if @comment.save
        format.js   { render :partial => 'comment'  }
        format.html {
          flash[:notice] = 'Comment was successfully screened.'
          redirect_to comment.commentable 
        }
        format.xml  { head :ok }
      else
        format.html { 
          flash[:notice] = 'Error screening comment.'
          redirect_to comment.commentable 
        }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # POST /comments
  # POST /comments.xml
  def create
    @comment = Comment.new(params[:comment])
    @comment.comment_type ||= CommentType.find_or_create_by_name('comment')
    
    respond_to do |format|
      if @comment.save
        format.js   { render :partial => 'comment'  }
        format.html {
          flash[:notice] = 'Comment was successfully created.'
          redirect_to comment.commentable 
        }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    @comment = Comment.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        flash[:notice] = 'Comment was successfully updated.'
        format.html { redirect_to(@comment) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
    @comment = Comment.find(params[:id])
    @commenter = @comment.creator
    @owner = @comment.commentable.try :user
    permit 'admin or (self of commenter) or (self of owner)'
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to(comments_url) }
      format.xml  { head :ok }
    end
  end
end
