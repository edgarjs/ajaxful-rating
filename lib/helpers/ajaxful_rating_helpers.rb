module Mimbles # :nodoc:
  module AjaxfulRating # :nodoc:

    # Helpers to submit/see ratings in a star-like fashion.
    module Helpers
      
      # Default options
      AJAXFUL_OPTIONS = {
        :param_name => 'stars',
        :enable_rate => true,
        :ul_class => 'ajaxful-rating',
        :li_id => "star-%d",
        :li_class => 'star',
        :include_clearer => true
      }
        
      # Generates a list of remote links to submit a rate,
      # and shows the current rating.
      # 
      # *Example*
      # 
      #   <%= ajaxful_rating_for @article, rate_article_path(@article) %> # =>
      # 
      #   <ul class="ajaxful-rating rateable">
      #     <li id="star-1" class="star on"><%= link_to_remote '*', :url => rate_article_path(@article, :stars => 1) %></li>
      #     <li id="star-2" class="star off"><%= link_to_remote '*', :url => rate_article_path(@article, :stars => 2) %></li>
      #   </ul>
      # 
      # *Options*
      # 
      # [<tt>:param_name</tt>] Name of the param passing the rate value. Default is +stars+.
      # [<tt>:enable_rate</tt>] Indicates if the list is linkable or not. Default is +true+.
      # [<tt>:ul_class</tt>] Class attribute for the ul tag. Default is <tt>ajaxful-rating</tt>.
      # [<tt>:li_id</tt>] Id attribute for each li tag, include %d to make them unique. Default is <tt>star-%d</tt>.
      # [<tt>:li_class</tt>] Class attribute for each li tag. Default is <tt>star</tt>.
      # [<tt>:include_clearer</tt>] Indicates if the last li item is a clearer (for CSS purposes). Default is +true+.
      def ajaxful_rating_for(rateable, url, options = {})
        _options = AJAXFUL_OPTIONS.merge(options)
        options.delete_if { |k, v| AJAXFUL_OPTIONS.has_key?(k) }
        
        items = ''
        concatenator = (url =~ /\/.+\?.+=.+\Z/i) ? '&' : '?'
        blank = image_tag('ajaxful_rating/blank.gif', :alt => '', :width => 25, :height => 25)
        
        1.upto(rateable.class.stars) do |star|
          options[:url] = "#{url}#{concatenator}#{_options[:param_name]}=#{star}"
          li_class = "#{_options[:li_class]} #{star <= rateable.rate_average ? 'on' : 'off'}"
          star_dp = _options[:enable_rate] ? link_to_remote(blank, options) : blank
          
          items << "\t#{content_tag(:li, star_dp, :class => li_class,
          :id => _options[:li_id] %star)}\n"
        end
        clearer = _options[:include_clearer] ? "\t#{content_tag(:li, '&nbsp;', :class => 'clearer')}\n" : ''
        
        content_tag(:ul, "\n#{items + clearer}",
          :class => _options[:ul_class] + (_options[:enable_rate] ? ' rateable' : ''))
      end
    end
  end
end