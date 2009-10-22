class Relationship < ActiveRecord::Base
  belongs_to :to_user, :class_name => 'User'
  belongs_to :from_user, :class_name => 'User'
  belongs_to :to_identity, :class_name => 'Identity'
  belongs_to :from_identity, :class_name => 'Identity'
  
  attr_accessible :to_user_id # Users only get to say who it's to
  
  include AASM
  aasm_column :state
  aasm_initial_state :passive
  aasm_state :passive # not sent yet; should only be true of 'stealth' relationships (e.g. multis) that the user isn't told about
  aasm_state :pending, :enter => :send_confirmation_request # sent to them in-app - still can be auto-changed (e.g. if out-of-app status changes)
  aasm_state :denied, :enter => :do_deny # answered 'no'
  aasm_state :active,  :enter => :send_reciprocation_notice # answered 'yes'
  aasm_state :suspended, :enter => :do_suspend # answered 'yes' but later one or the other changed to 'no'
  
  validates_uniqueness_of :to_user_id, :scope => :from_user_id, :allow_nil => true
  validates_uniqueness_of :to_identity_id, :scope => :from_identity_id, :allow_nil => true
  
  named_scope :multis, :conditions => {:multi => true}
  
  def validate
    (to_user_id != from_user_id or !to_user_id or !from_user_id) and                   # can't friend yourself
    (to_identity_id != from_identity_id or !to_identity_id or !from_identity_id) and
    ((to_user_id and from_user_id) or (to_identity_id and from_identity_id))           # has to have *some* ID
  end
  
  aasm_event :request_confirmation do
    transitions :from => [:pending, :passive], :to => :pending  # (re)send activation code
  end
  
  aasm_event :confirm do
    transitions :from => :pending, :to => :active
  end
  
  aasm_event :deny do
    transitions :from => :pending, :to => :denied
  end
  
  aasm_event :suspend do
    transitions :from => [:passive, :pending, :active], :to => :suspended
  end
  
  aasm_event :unsuspend do
    transitions :from => :suspended, :to => :active,  :guard => Proc.new {|u| !u.activated_at.blank? }
    transitions :from => :suspended, :to => :pending, :guard => Proc.new {|u| !u.confirmation_requested_at.blank? }
    transitions :from => :suspended, :to => :passive
  end
  
  def send_confirmation_request
    self.confirmation_requested_at = Time.now.utc
    RelationshipMailer.deliver_confirmation_request(self)
  end
  
  def send_reciprocation_notice
    self.activated_at = Time.now.utc
    r = reciprocal
    r.state = 'active'
    r.activated_at = Time.now.utc
    r.save
    RelationshipMailer.deliver_reciprocation_notice(self)
  end
  
  def reciprocal
    Relationship.find_or_initialize_by_to_user_id_and_from_user_id(self.from_user_id, self.to_user_id)
  end
  
  def do_deny
    self.denied_at = Time.now.utc
  end
  
  def do_suspend
    self.suspended_at = Time.now.utc
  end
end
