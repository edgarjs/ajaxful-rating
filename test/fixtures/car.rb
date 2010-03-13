class Car < ActiveRecord::Base
  ajaxful_rateable :stars => 10, :dimensions => [:speed, :reliability, :price]
end
