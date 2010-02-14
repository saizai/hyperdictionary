class EventEventable < ActiveRecord::Base
  belongs_to :event
  belongs_to :event_type
  belongs_to :eventable, :polymorphic => true
  
  scope :recent, lambda {|limit, page| limit(limit).offset((page - 1) * limit) }
  scope :with_eventables, lambda {|eventables| where((['(event_eventables.eventable_id = ? and event_eventables.eventable_type = ?)'] * eventables.size).join(' OR '), *eventables.inject([]){|m,v| m << v.id; m << v.class.name; m }) } 
  
  # this is called multiple times if saving when associated with a new record
  # therefore we do ||= so that it's only really used the first time
  def before_validation_on_create
    self.event_type_id ||= event.event_type_id # might be set directly. Must be identical to event.event_type_id, but we don't bother checking
    self.index ||= if !(previous = self.previous)
      1
    elsif previous.created_at > 4.hours.ago
      previous.index # aggregate if it's within the aggregation period
    else
      previous.index + 1
    end
  end
  
  # Gets all events aggregated from the POV of a particular target
  # Meant to be called with appropriate scope, but it could be used directly (to get e.g. all recent events); aggregation in that usage will be weird.
  # e.g. Page.first.event_eventables.recent(20,1).aggregated_events
  # Also, this is currently non-cacheable and moderately expensive. Only call when needed.
  def self.aggregated_events
    grouped_event_ids = self.select("GROUP_CONCAT(event_id) as event_ids").group('event_type_id, role, event_eventables.index').order('MAX(updated_at) DESC').map{|x| x.event_ids.split(',').map(&:to_i).uniq}.uniq
    events = Event.where("id IN (?)", grouped_event_ids.flatten).include(:event_type, {:event_eventables => :eventable}).inject({}){|m,x| m[x.id] = x; m} # this part is just a hack to let us only call id once, in prep for:
    grouped_event_ids.map!{|group| 
      group.map!{|id| events.delete(id) } # moves those events in cheaply
      group.delete(nil) # in case of duplicates
      next if group.blank?
      result = Hash.new([]) # unfound items default to empty list
      event_type = group.first.event_type # they should all be the same, if the index was set properly
      updated_at =  group.first.updated_at
      group.map{|x| x.event_eventables.map{|y| result[y.role.to_sym] = result[y.role.to_sym] | [y.eventable] } } # | = union, i.e. drop dupes
      {:event_type => event_type, :updated_at => updated_at, :roles => result}
    }
    grouped_event_ids.delete_if{|x| x.blank?}
  end
  
  def previous
    prev = Eventable.where(:event_type_id => self.event_type_id, :eventable_type => self.eventable_type,
                            :eventable_id => self.eventable_id, :role => self.role).order('event_eventables.index')
    prev = prev.offset(1) if !self.new_record? 
    prev.last
  end
end
