class Rate < ActiveRecord::Base
  belongs_to :<%= file_name %>
  belongs_to :rateable, :polymorphic => true
  
  attr_accessible :rate, :dimension
end
