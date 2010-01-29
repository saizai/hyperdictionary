class Event < ActiveRecord::Base
  belongs_to :event_type
  has_many :event_eventables
  has_many_polymorphs :eventables, :through => :event_eventables, :from => [:pages, :users, :identities, :discussions, :messages]
  
  named_scope :recent, lambda {|limit, page| {:limit => limit, :offset => (page - 1) * limit}}
  
  validates_presence_of :released_at, :event_type_id
  
  # TODO: module on has_many :events for targets
  
  def before_validation_on_create
    self.created_at = self.updated_at = Time.now
    self.released_at ||= self.created_at
  end
  
  def self.event! agent, event_name, other_roles = nil # should be a hash e.g. :patient => @page or @pages, :instrument => @bar - or just an item and it'll be :patient
    event_type = EventType.find_or_create_by_name(event_name)
    e = self.new :event_type => event_type
    e.event_eventables.build :eventable => agent, :event_type => event_type
    other_roles = {:patient => other_roles} unless other_roles.nil? or other_roles.is_a? Hash
    other_roles.each {|role, target_array|
      [target_array].flatten.each {|target| # coerces it to be an array, so we can accept both single items and collections
        e.event_eventables.build :eventable => target, :role => role.to_s, :event_type => event_type
      }
    } if other_roles
    
    # this is just called in order to invoke the validity checker (which has to do finds) 
    #  and thereby make the following (transactioned) save statement slightly less blocking (= faster w/ multiple processes)
    e.valid? 
    e.save # save all of 'em in one go
  end
  
#  def self.aggregated
#    # This is a total hack. Surely there's a better way to find who called us?
#    # Returns something like ["User", "4"]
#    caller = self.scope(:find)[:conditions].scan(/eventable_type = '(\w*)'.*eventable_id = (\d*)/)[0]
#    events = self.find(:all, :include => [:event_type, :event_eventables], :group => 'event_eventables.index')
#    
#    events.group_by{|e| "#{e.event_type} #{e.eventables.detect{|ee| ee.eventable_type == caller[0] and ee.eventable_id == caller[1] }.role}"}
#  end
end
