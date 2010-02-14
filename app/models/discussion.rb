class Discussion < ActiveRecord::Base
  has_many :contextualizations
  has_many_polymorphs :contexts, :through => :contextualizations, :from => [:fora, :pages, :users]
  has_many :messages, :dependent => :destroy, :inverse_of => :discussion
  has_many :split_messages, :class_name => "Message", :conditions => "split_discussion_id IS NOT NULL"
  has_many :split_discussions, :through => :split_messages, :source => :split_discussion
  has_many :merged_messages, :class_name => "Message", :foreign_key => :split_discussion_id
  has_many :merged_discussions, :through => :merged_messages, :source => :discussion
  has_many :participations
  has_many :participants, :through => :participations, :source => :user
  belongs_to :last_message, :class_name => "Message"
  
  accepts_nested_attributes_for :messages # , :reject_if => :all_blank # this would discard messages that are blank; 
                                                                       # instead hopefully we want to raise an error
  acts_as_authorizable
  acts_as_paranoid
  acts_as_taggable
  stampable
  acts_as_versioned :version_column => 'lock_version'
  
  validates :messages_count, :next_message, :presence => true #, :context, :sticky, :locked, :screened
  # name can be blank; creator/updater should be taken care of by model_stamper
  validate :must_have_messages
  
  def must_have_messages
    errors.add_to_base "Can't have a thread with no messages" if messages.empty?
  end
  
  attr_accessor :to_user, :participation
  
  before_validation_on_create :set_participants #, :initialize_messages
  
  def set_participants
    if to_user # i.e., if this was created from inbox view
      self.mark_read_by! User.find(to_user), true
      self.mark_read_by! creator, true
    end
  end
  
#  def set_forum
#    if fora.blank?
#      # TODO: find the correct forum/a to attach to automatically
#      fora.create(:name => pages.first.name + ' forum')
#    end
#  end
  
  def set_context_from_to_user
    self.context = User.find(to_user) if to_user
  end
  
  def mark_read_by! user, subscribe = false
    if p = participations.where(:user_id => user.id).first
      p.mark_read! subscribe
    else
      Participation.create :user_id => user.id, :discussion_id => self.id, :last_read => Time.now, :inbox => subscribe
    end
  end
  
  def visible_to? user
    true
  end
  
  def commented_by? user
    true
  end
  
  def moderated_by? user
    false
  end
  
  def screened_by? user
    false
  end
  
  def deleted_by? user
    false
  end
  
end