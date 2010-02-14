class Preference < ActiveRecord::Base
  acts_as_authorizable
  
  belongs_to :preferrer, :polymorphic => true
  belongs_to :preferred, :polymorphic => true
  
  serialize :value
  validates_length_of :name, :within => 1..128
  validates_uniqueness_of :name, :on => :create, :scope => [ :preferrer_id, :preferrer_type, 
                                                             :preferred_id, :preferred_type ]
  validates_presence_of :preferrer
  validates_presence_of :name
  validates_associated :preferred
  
  default_scope order('name')
  
  def to_s
    if preferred and (preferred != preferrer)
      "#{name} #{preferred_type} #{preferred_id and preferred.respond_to? :name ? preferred.name : preferred.id}".strip
    else
      name
    end
  end  
end
