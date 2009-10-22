class RelationshipsController < ApplicationController
  before_filter :find_user
  
  def create
    # @user is the SOURCE user
    @relationship = @user.relationships.new(params[:relationship])
    
    permit 'site_admin or (self of user)' do
      success = @relationship.request_confirmation! if @relationship and @relationship.valid?
      if success and @relationship.errors.empty?
        respond_to do |format|
          format.js   { head :ok  }
          format.html {
            flash[:notice] = "Friend added! (We'll let you know if they reciprocate.)" 
            redirect_back_or_default @relationship.to_user
          }
          format.xml { head :ok }
        end
      else
# TODO: handle error
      end
    end
  end
  
  def confirm
    # @user is the SOURCE user of the existing (one-way) relationship
    @relationship = @user.relationships.find(params[:id])
    @to_user = @relationship.to_user
    
    permit 'site_admin or (self of to_user)' do
      success = case params[:response]
        when 'approve'
          approve = true
          @relationship.confirm!
        when 'deny'
          approve = false
          @relationship.deny!
        else
          raise "Malformed link" # TODO: handle error better
      end if @relationship.valid?
      
      if success and @relationship.errors.empty?
        respond_to do |format|
          format.js   { head :ok  }
          format.html {
            flash[:notice] = approve ? "Added #{link_to_user relationship.from_user} as a friend!" :
              "Ignored #{link_to_user relationship.from_user}'s friendship request. (Visit their profile if you change your mind.)" 
            redirect_back_or_default @relationship.from_user
          }
          format.xml { head :ok }
        end
      else
# TODO: handle error
      end
    end
  end
  
  protected
  
  def find_user
    @user = User.find(params[:user_id])
  end
end
