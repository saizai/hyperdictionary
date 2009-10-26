class IdentitiesController < ApplicationController
  before_filter :login_required
  before_filter :find_user
  
  def screen
    @identity = @user.identities.find(params[:id])
    permit 'site_admin or (self of user)' do
      @identity.toggle :public
      
      respond_to do |format|
        if @identity.save
          format.js   { render :partial => 'identity'  }
          format.html {
            flash[:notice] = 'Identity was successfully screened.'
            redirect_to @user 
          }
          format.xml  { head :ok }
        else
          format.js   { render :partial => 'Identity'  }  # TODO: handle errors better
          format.html { 
            flash[:notice] = 'Error screening contact.'
            redirect_to @user
          }
          format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
        end
      end
    end
  end
  
  protected
  
  def find_user
    @user = User.find(params[:user_id])
  end

end
