class Rate < ActiveRecord::Base
  belongs_to :rateable, :polymorphic => true
  belongs_to :user
  
  attr_accessible :rate
end