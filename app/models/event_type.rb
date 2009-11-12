class EventType < ActiveRecord::Base
  has_many :events
  has_many :event_eventables
  has_many_polymorphs :eventables, :through => :event_eventables, :from => [:pages, :users, :identities, :discussions, :messages]
  
end
