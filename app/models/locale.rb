class Locale < ActiveRecord::Base
  acts_as_paranoid
  acts_as_versioned :version_column => 'lock_version'
  acts_as_tree :order => :name
  has_friendly_id :abbreviation
  
  validates_presence_of :abbreviation
  validates_uniqueness_of :abbreviation
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_associated :parent  
end
