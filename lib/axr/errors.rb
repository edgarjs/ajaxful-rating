module AjaxfulRating # :nodoc:
  module Errors
    class AlreadyRatedError < StandardError
      def to_s
        "Model has already been rated by this user. To allow update of ratings pass :allow_update => true to the ajaxful_rateable call."
      end
    end
    
    class MissingRateRoute < StandardError
      def to_s
        "Add a member route to your routes file for rate with :post method. Or specify a custom url in the options."
      end
    end
    
    class NoUserSpecified < StandardError
      def to_s
        "You need to specify a user instance or create a helper with the name current_user."
      end
    end
    
    class MissingStarsCSSBuilder < StandardError
      def to_s
        "Add a call to ajaxful_rating_style within the head of your layout."
      end
    end
  end
end
