# Not implemented yet

class PageSweeper < ActionController::Caching::Sweeper
  observe Page
  
  def after_save(record)
    expire_cache_for(record)
  end
  
  alias after_destroy after_save
          
  private
  def expire_cache_for(record)
    Page::ROLES.each {|role| expire_fragment :controller => "pages", :action => "show", :id => self.id, :action_suffix => role }
  end
end