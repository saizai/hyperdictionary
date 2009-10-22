class Contact < ActiveRecord::Base
  belongs_to :contact_type
  belongs_to :user, :touch => true
  delegate :verifiable, :email?, :to => :contact_type
  # data
  # public
  # preverified
  
  validates_uniqueness_of :data, :scope => :contact_type_id
  validates_presence_of :user
#  validates_associated :user
  validates_presence_of :contact_type
#  validates_associated :contact_type
  validates_length_of :data, :minimum => 1
  
  validates_email_veracity_of :data, :if => Proc.new {|c| c.contact_type_id == ContactType.find_by_name('email').id}
  
  named_scope :emails, :conditions => {:contact_type_id => ContactType.find_by_name('email').id }
  named_scope :public, :conditions => {:public => true}
  
  def before_validation
    unless self.contact_type_id == ContactType.find_by_name('address').id
      data.downcase!
    end
    data.strip!
    data = nil if data.blank?
  end
  
  # State management
  
  attr_accessor :activation_code_entered # used when they respond to an activation request
  attr_accessor :recently_registered
  
  include AASM  
  aasm_column :state
  aasm_initial_state :passive
  aasm_state :passive
  aasm_state :pending, :enter => :make_activation_code
  aasm_state :active,  :enter => :do_activate
  aasm_state :suspended
  aasm_state :deleted, :enter => :do_delete
  
  aasm_event :register do
    transitions :from => :passive, :to => :active, :guard => Proc.new {|c| !c.verifiable or c.preverified } # not verifiable or preverified, so skip straight to active
    transitions :from => [:pending, :passive], :to => :pending  # (re)send activation code
  end
  
  aasm_event :activate do
    transitions :from => [:passive, :pending], :to => :active, :guard => Proc.new {|c| c.activation_code == c.activation_code_entered }
  end
  
  aasm_event :suspend do
    transitions :from => [:passive, :pending, :active], :to => :suspended
  end
  
  aasm_event :delete do
    transitions :from => [:passive, :pending, :active, :suspended], :to => :deleted
  end

  aasm_event :unsuspend do
    transitions :from => :suspended, :to => :active,  :guard => Proc.new {|u| !u.activated_at.blank? }
    transitions :from => :suspended, :to => :pending, :guard => Proc.new {|u| !u.activation_code.blank? }
    transitions :from => :suspended, :to => :passive
  end
  
  def do_delete
    self.deleted_at = Time.now.utc
  end
  
  def do_activate
    self.activated_at = Time.now.utc
    self.deleted_at = self.activation_code = nil
  end
    
  protected
  
  def make_activation_code
    return unless verifiable
    self.recently_registered = true
    self.deleted_at = nil
    self.activation_code = SecureRandom.hex 10
  end
end
