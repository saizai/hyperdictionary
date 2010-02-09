class AssetsController < ApplicationController
  before_filter :login_required
  
  # GET /assets
  # GET /assets.xml
#  def index
#    @assets = Asset.find(:all, :conditions => {:parent_id => nil})
#    
#    respond_to do |format|
#      format.html # index.html.erb
#      format.xml  { render :xml => @assets }
#    end
#  end

  # GET /assets/1
  # GET /assets/1.xml
#  def show
#    @asset = Asset.find(params[:id])
#
#    respond_to do |format|
#      format.html # show.html.erb
#      format.xml  { render :xml => @asset }
#    end
#  end

  # GET /assets/new
  # GET /assets/new.xml
#  def new
#    @asset = Asset.new
#
#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => @asset }
#    end
#  end

  # GET /assets/1/edit
#  def edit
#    @asset = Asset.find(params[:id])
#  end

  # POST /assets
  # POST /assets.xml
  def create
    @asset = Asset.new(params[:asset])
    @asset.creator_id = @asset.updater_id = current_user.id

    respond_to do |format|
      if @asset.save
        flash[:notice] = 'Asset was successfully created.'
        format.html { redirect_to(@asset) }
        format.xml  { render :xml => @asset, :status => :created, :location => @asset }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @asset.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def download
    @asset = Asset.find(params[:id])
    send_file("#{Rails.root}/public"+@asset.public_filename, 
      :disposition => 'attachment',
      :encoding => 'utf8', 
      :type => @asset.content_type,
      :filename => URI.encode(@asset.filename)) 
  end

  skip_before_filter :footnotes_before_if, :only => :swfupload
  skip_after_filter :footnotes_after_if, :only => :swfupload
  def swfupload
    # swfupload action set in routes.rb
    @asset = Asset.new :uploaded_data => params[:Filedata], :attachable_type => params[:attachable_type], :attachable_id => params[:attachable_id]
    @asset.creator_id = @asset.updater_id = current_user.id
    @asset.save!
    
    # This returns the thumbnail url for handlers.js to use to display the thumbnail
    render :text => @asset.public_filename(:thumb)
  rescue Exception => e
    logger.error e    
    render :text => "Error"
  end
  
  # PUT /assets/1
  # PUT /assets/1.xml
#  def update
#    @asset = Asset.find(params[:id])
#
#    respond_to do |format|
#      if @asset.update_attributes(params[:asset])
#        flash[:notice] = 'Asset was successfully updated.'
#        format.html { redirect_to(@asset) }
#        format.xml  { head :ok }
#      else
#        format.html { render :action => "edit" }
#        format.xml  { render :xml => @asset.errors, :status => :unprocessable_entity }
#      end
#    end
#  end

  # DELETE /assets/1
  # DELETE /assets/1.xml
  def destroy
    @asset = Asset.find(params[:id])
    @creator = @asset.creator
    permit 'site_admin or (self of creator)' do
      @asset.destroy
      
      respond_to do |format|
        format.js   { head :ok }
        format.html { redirect_to(assets_url) }
        format.xml  { head :ok }
      end
    end
  end
end
