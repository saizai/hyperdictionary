class MakeIdentitiesUnique < ActiveRecord::Migration
  def self.up
    remove_index :identities, :url
    Identity.find(:all, :group => :url, :select => 'max(id) as id, count(*) as count, url',
      :having => 'count > 1').each{|x| 
        Identity.find(:all, :conditions => ['url = ? and id < ?', x.url, x.id]).each{|y| y.destroy} 
      }
    add_index :identities, :url, :unique => true
  end

  def self.down
    remove_index :identities, :url
    add_index :identities, :url
  end
end
