class Contextualization < ActiveRecord::Base
  belongs_to :discussion, :counter_cache => :contexts_count
  belongs_to :context, :polymorphic => true
  
end
