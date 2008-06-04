require 'ajaxful_rating'
require 'helpers/ajaxful_rating_helpers'

ActiveRecord::Base.send(:include, Mimbles::AjaxfulRating)
ActionView::Base.send(:include, Mimbles::AjaxfulRating::Helpers)