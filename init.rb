require 'ajaxful_rating'
require 'ajaxful_rating_helper'

ActiveRecord::Base.send(:include, AjaxfulRating) unless ActiveRecord::Base.include?(AjaxfulRating)
ActionView::Base.send(:include, AjaxfulRating::Helper) unless ActionView::Base.include?(AjaxfulRating::Helper)
