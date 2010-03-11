class Rate < ActiveRecord::Base
  belongs_to :rater, :class_name => "<%= file_name.classify %>"
  belongs_to :rateable, :polymorphic => true
  
  attr_accessible :rate, :dimension
end
