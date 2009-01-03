module AjaxfulRating # :nodoc:
  module Helper
    class MissingRateRoute < StandardError
      def to_s
        "Add :member => {:rate => :post} to your routes, or specify a custom url in the options."
      end
    end
  
    # Generates the stars list to submit a rate.
    # 
    # It accepts the next options:
    # * <tt>:class</tt> CSS class for the ul. Default is 'ajaxful-rating'.
    # * <tt>:link_class_prefix</tt> Prefix for the li a CSS class. Default is 'stars'.
    # * <tt>:small_stars</tt> Set this param to true to display smaller images. Default is false.
    # * <tt>:small_star_class</tt> CSS class for the list when using small images. Default is 'small-stars'.
    # * <tt>:html</tt> Hash of options to customise the ul tag.
    # * <tt>:remote_options</tt> Hash of options for the link_to_remote function.
    # Default is {:method => :post, :url => rate_rateablemodel_path(rateable)}.
    # * <tt>:wrap</tt> Whether the star list is wrapped within a div tag or not. This is useful when page updating. Default is true.
    # 
    # Example:
    #   <%= ratings_for @article %>
    #   # => Will produce something like:
    #   <ul class="ajaxful-rating">
    #     <li class="current-rating" style="width: 60%;">Currently 3/5 stars</li>
    #     <li><%= link_to_remote 1, :url => rate_article_path(@article, :stars => 1), :method => :post, :html => {:class => 'stars-1', :title => '1 star out of 5'} %></li>
    #     <li><%= link_to_remote 2, :url => rate_article_path(@article, :stars => 2), :method => :post, :html => {:class => 'stars-2', :title => '2 stars out of 5'} %></li>
    #     <li><%= link_to_remote 3, :url => rate_article_path(@article, :stars => 3), :method => :post, :html => {:class => 'stars-3', :title => '3 stars out of 5'} %></li>
    #     <li><%= link_to_remote 4, :url => rate_article_path(@article, :stars => 4), :method => :post, :html => {:class => 'stars-4', :title => '4 stars out of 5'} %></li>
    #     <li><%= link_to_remote 5, :url => rate_article_path(@article, :stars => 5), :method => :post, :html => {:class => 'stars-5', :title => '5 stars out of 5'} %></li>
    #   </ul>
    #   
    # It will try to use the method <tt>current_user</tt> as the user instance. You can specify a custom instance in the second parameter
    # or pass <tt>:static</tt> to leave the list of stars static.
    # 
    # Example:
    #   <%= ratings_for @article, @user, :small_stars => true %>
    #   # => Will use @user instead <tt>current_user</tt>
    #   
    #   <%= ratings_for @article, :static, :small_stars => true %>
    #   # => Will produce a static list of stars showing the current rating average for @article.
    #   
    # The user passed here will *not* be the one who submits the rate. It will be used only for the display behavior of the stars.
    # Like for example, if there is a user logged in or if the current logged in user is able to submit a rate depending on the
    # configuration (accepts update of rates, etc).
    # 
    # So to actually set the user who will rate the model you need to do it in your controller:
    # 
    #   # controller
    #   def rate
    #     @article = Article.find(params[:id])
    #     @article.rate(params[:stars], current_user) # or any user instance
    #     # update page, etc.
    #   end
    # 
    # I18n:
    # 
    # You can translate the title of the images (the tool tip that shows when the mouse is over) and the 'Currently x/x stars'
    # string by setting these keys on your translation hash:
    # 
    #   ajaxful_rating:
    #     stars:
    #       current_average: "Current rating: {{average}}/{{max}}"
    #       title:
    #         one: 1 star out of {{total}}
    #         other: "{{count}} stars out of {{total}}"
    def ratings_for(rateable, *args)
      user = extract_options(rateable, *args)
      ajaxful_styles << %Q(
      .#{options[:class]} { width: #{rateable.class.max_rate_value * 25}px; }
      .#{options[:small_star_class]} { width: #{rateable.class.max_rate_value * 10}px; }
      )
      width = (rateable.rate_average(true, options[:dimension]) / rateable.class.max_rate_value.to_f) * 100
      ul = content_tag(:ul, options[:html]) do
        Range.new(1, rateable.class.max_rate_value).collect do |i|
          build_star rateable, user, i
        end.insert(0, content_tag(:li, current_average(rateable),
            :class => 'current-rating', :style => "width:#{width}%"))
      end
      if options[:wrap]
        content_tag(:div, ul, :id => "ajaxful-rating-#{!options[:dimension].blank? ?
          "#{options[:dimension]}-" : ''}#{rateable.class.name.downcase}-#{rateable.id}")
      else
        ul
      end
    end
  
    # Call this method <strong>within head tags</strong> of the main layout to yield the dynamic styles.
    # It will include the necessary stlyesheet and output the dynamic CSS.
    #
    # Example:
    #   <head>
    #     <%= ajaxful_rating_style %>
    #   </head>
    def ajaxful_rating_style
      stylesheet_link_tag('ajaxful_rating') + content_tag(:style, ajaxful_styles,
        :type => 'text/css') unless ajaxful_styles.blank?
    end
  
    private
  
    # Builds a star
    def build_star(rateable, user, i)
      a_class = "#{options[:link_class_prefix]}-#{i}"
      ajaxful_styles << %Q(
        .#{options[:class]} .#{a_class}{
            width: #{(i / rateable.class.max_rate_value.to_f) * 100}%;
            z-index: #{rateable.class.max_rate_value + 2 - i};
        }
      )
      rated = rateable.rated_by?(user, options[:dimension]) if user
      star = if user && ((rated && rateable.class.options[:allow_update]) || !rated)
        link_to_remote(i, build_remote_options({:class => a_class, :title => pluralize_title(i, rateable.class.max_rate_value)}, i))
      else
        content_tag(:span, i, :class => a_class, :title => current_average(rateable))
      end
      content_tag(:li, star)
    end
  
    # Default options for the helper.
    def options
      @options ||= {
        :wrap => true,
        :class => 'ajaxful-rating',
        :link_class_prefix => :stars,
        :small_stars => false,
        :small_star_class => 'small-star',
        :html => {},
        :remote_options => {:method => :post}
      }
    end
  
    # Builds the proper title for the star.
    def pluralize_title(current, max)
      (current == 1) ? I18n.t('ajaxful_rating.stars.title.one', :max => max, :default => "1 star out of {{max}}") :
        I18n.t('ajaxful_rating.stars.title.other', :count => current, :max => max, :default => "{{count}} stars out of {{max}}")
    end
    
    # Returns the current average string.
    def current_average(rateable)
      I18n.t('ajaxful_rating.stars.current_average', :average => rateable.rate_average(true, options[:dimension]),
        :max => rateable.class.max_rate_value, :default => "Current rating: {{average}}/{{max}}")
    end
  
    # Temporary instance to hold dynamic styles.
    def ajaxful_styles
      @ajaxful_styles ||= ''
    end
  
    # Builds the default options for the link_to_remote function.
    def build_remote_options(html, i)
      options[:remote_options].reverse_merge(:html => html).merge(
        :url => "#{options[:remote_options][:url]}?#{{:stars => i, :dimension => options[:dimension]}.to_query}")
    end
  
    # Extracts the hash options and returns the user instance.
    def extract_options(rateable, *args)
      user = if args.first.class.name == rateable.class.user_class_name.classify
        args.shift
      elsif args.first != :static
        current_user if respond_to?(:current_user)
      end
      options.merge!(args.last) if !args.empty? && args.last.is_a?(Hash)
      options[:remote_options][:url] ||= respond_to?(url = "rate_#{rateable.class.name.downcase}_path") ?
        send(url, rateable) : raise(MissingRateRoute)
      options[:html].reverse_merge!(:class => "#{options[:class]} #{options[:small_star_class] if options[:small_stars]}")
      user
    end
  end
end
