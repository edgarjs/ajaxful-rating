module AjaxfulRating # :nodoc:
  
  # Customize messages by adding I18n keys:
  #
  #   ajaxful_rating:
  #     helper:
  #       global_average: "Current rating average: {{value}} out of {{max}}"
  #       user_rating: "Your rating: {{value}} out of {{max}}"
  module Locale
    def i18n(global = true)
      key = "ajaxful_rating.helper.#{global ? 'global_average' : 'user_rating'}"
      default =
        if global
          "Current rating average: {{value}} out of {{max}}"
        else
          "Your rating: {{value}} out of {{max}}"
        end
      I18n.t(key, :value => show_value, :max => rateable.class.max_stars, :default => default)
    end
  end
end
