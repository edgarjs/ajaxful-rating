require 'ajaxful_rating'
require 'helpers/ajaxful_rating_helpers'

ActiveRecord::Base.send(:include, AjaxfulRating)
ActionView::Base.send(:include, AjaxfulRating::Helpers)