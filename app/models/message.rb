class Message < ActiveRecord::Base
  belongs_to :creator
  belongs_to :context, :polymorphic => true
  belongs_to :parent, :class_name => "Message"
  has_many :children, :class_name => "Message", :foreign_key => "parent_id"
  belongs_to :discussion, :inverse_of => :messages #, :autosave => true
  belongs_to :split_discussion, :class_name => "Discussion"
  belongs_to :message_interface
  # index
  # locked, private, moderated
  # body
  # children_count, next_child
  
  scope :inbox, where(:message_interface_id => MessageInterface.find_or_create_by_name('inbox').id)
  
  acts_as_authorizable
  acts_as_paranoid
  acts_as_taggable
  stampable
  acts_as_versioned :version_column => 'lock_version'
  
  validates_presence_of :body, :message_interface, :context, :index
  validates_numericality_of :children_count, :next_child
  validate :context_must_be_in_discussion
#  validates_associated :creator # but not its presence
#  validates_associated :updater
#  validates_associated :deleter
#  validates_associated :context
  
  scope :since, lambda{|time| where('messages.updated_at > ?', time)}
  scope :by_index, order('discussions.updated_at DESC, messages.index ASC').includes(:discussion)
  attr_accessor :title, :interface
  
  def context_must_be_in_discussion
    errors.add_to_base "Message's context must be in discussion." if context and discussion.context_ids.include?(context_id)
  end
  
  def visible_to? user
    return true if context.nil? or !context.respond_to? :read_by
    user ||= AnonUser
    context.read_by?(user) and
      (!moderated or context.moderated_by? user) and
      (!private or context.member_by? user or (creator_id and user.id == creator_id)) # AnonUser cannot see their own screened posts
  end
  
  def moderated_by? user
    return false if context.nil? or !context.respond_to? :read_by
    context.moderated_by? user
  end
  
  def screened_by? user
    return false if context.nil? or !context.respond_to? :read_by
    context.member_by? user
  end
  
  def deleted_by? user
    return false if context.nil? or !context.respond_to? :read_by
    context.owned_by? user
  end
  
  def after_create
    # The fancy method_missing 'has_subscribers' fails on polymorphic associations for some reason
    (context.has_roles('subscriber') - [creator]).each {|subscriber| MessageMailer.new_message(self, subscriber).deliver }
    discussion.update_attribute :last_message_id, self.id
    Discussion.update_counters discussion_id, :messages_count => 1, :next_message => (parent ? 0 : 1 ) # next_message is used for indexing; only updated for first-level children
    Message.update_counters parent_id, :children_count => 1, :next_child => 1 if parent
  end
  
  def before_destroy
    Discussion.decrement_counter :messages_count, discussion_id # next_foo is monotonic
    Message.decrement_counter :children_count, parent_id
  end
  
  def title
    @title || self.discussion.try(:name) 
  end
  
  def before_validation_on_create
    self.body.strip!
    self.discussion ||= if parent and (title.blank? or (title == parent.title))
      parent.discussion
    else
      Discussion.new :context => self.context, :name => self.title
    end
    self.message_interface ||= MessageInterface.find_by_name(self.interface)
    self.context ||= discussion.context
    set_index
  end
  
  def validate_on_create
    errors.add_to_base("That was already posted.") if context and context.messages.last and (context.messages.last.body == self.body)
  end
  
  def set_index force = false
    return self.index unless force or self.index.blank?
    self.index = if parent and (title.blank? or title == parent.title)
      parent.index + '.' + Message.munge_number(parent.next_child)
    else
      Message.munge_number(discussion.next_message)
    end
  end
  
  # Meant primarily for moving an entire tree at once to a new place (e.g. discussionsplit or merge).
  def rebase! new_parent, splitter_id, new_discussion_title = nil
    return false if !self.split_discussion_id.nil? # don't double-redirect
    
    old_index = self.index.dup
    old_discussion_id = self.discussion_id
    old_parent = self.parent
    old_context = self.context 
    split_notice = Message.new(:discussion => self.discussion, :context => self.context, :creator_id => splitter_id, 
      :parent => self.parent, :index => self.index, :message_interface => MessageInterface.find_by_name("auto"),
      :body => "Discussion moved")
    
    if new_parent.is_a? Message
      self.parent = new_parent
      self.discussion = new_parent.discussion
      self.context = new_parent.context
    elsif new_parent.is_a? Discussion
      self.parent = nil
      self.discussion = new_parent
      self.context = new_parent.context
    else # it *is* a context... hopefully
      self.parent = nil
      self.discussion = Discussion.new :name => new_discussion_title || "Moved from #{self.discussion.name}", :context => self.context, :creator_id => splitter_id, :updater_id => splitter_id
      self.context = new_parent
    end
    new_index = set_index true
    split_notice.split_discussion = self.discussion
    
    Message.transaction do
      self.save # do first so that discussion_id is set
      # do next so we can reuse the first part of the index. This operates on this one too.
      Message.update_all "context_id = #{context_id}, context_type = '#{context_type}'",
        "discussion_id = #{old_discussion_id} AND messages.index LIKE '#{old_index}.%' AND  
          context_id = #{ old_context.id } AND context_type = '#{ old_context.class }'"
      # mysql INSERT: (string to change, starting position [1-based], number chars to replace, string to insert)
      Message.update_all "discussion_id = #{discussion_id}, messages.index = INSERT(messages.index, 1, #{old_index.length}, '#{new_index}')", 
        "discussion_id = #{old_discussion_id} AND messages.index LIKE '#{old_index}.%'"
      split_notice.save
    end
    
  end
  
  # This is a hack. It works around the fact that mysql sorts '1.10' after '1.9' by converting it to '1.A10', and so on.
  # It's a bit ugly, but it works and is cheap.
  def self.munge_number number
    if number < 100
      number.to_s
    else
      # 65 = ASCII 'A'. Minimum is 2 (for 1 we don't have a prefix), so 63 + 2 = 'A', +3 = 'B', etc. 
      # Technically, only using one letter here means we're limited to 10^27 children at a given level.
      # I think we'll manage without an octillion comments...
      (63 + number.to_s.length).chr + number.to_s # .chr converts integer to the ASCII character equivalent
    end
  end
  
  def level
    self.index.count('.')
  end
end
