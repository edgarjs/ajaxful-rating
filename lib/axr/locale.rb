module AjaxfulRating # :nodoc:
  
  # Customize messages by adding I18n keys:
  #
  #   ajaxful_rating:
  #     helper:
  #       global_average: "Global rating average: {{value}} out of {{max}}"
  #       user_rating: "Your rating: {{value}} out of {{max}}"
  #       hover: "Rate {{value}} out of {{max}}"
  module Locale
    
    DEFAULTS = {
      :user_rating => "Your rating: {{value}} out of {{max}}",
      :global_average => "Global rating average: {{value}} out of {{max}}",
      :hover => "Rate {{value}} out of {{max}}",
      :no_ratings => "Not yet rated"
    }
    
    def i18n(key, value = nil)
      key = if key == :current
        options[:show_user_rating] ? :user_rating : :global_average
      else
        key.to_sym
      end
      key = :no_ratings if key == :user_rating && options[:show_user_rating] && ((value || show_value) == 0)
      default = DEFAULTS[key]
      key = "ajaxful_rating.helper.#{key}"
      I18n.t(key, :value => (value || show_value),
        :max => rateable.class.max_stars, :default => default)
    end
  end
end
