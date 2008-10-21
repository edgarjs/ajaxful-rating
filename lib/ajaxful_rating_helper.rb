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
    # * <tt>:title_singular</tt> String format to display as img title when singular. Accepts 1 digit param,
    # which is the total of stars. Default is "1 star out of %d".
    # * <tt>:title_plural</tt> String format to display as img title when singular. Accepts 2 digit params,
    # the first one is the current star and the second is the total of stars. Default is "%d stars out of %d".
    # * <tt>:current</tt> String format to display as the current rating average. Default is "Currently %d/%d stars".
    # * <tt>:small_stars</tt> Set this param to true to display smaller images. Default is false.
    # * <tt>:small_star_class</tt> CSS class for the list when using small images. Default is 'small-stars'.
    # * <tt>:html</tt> Hash of options to customise the ul tag.
    # * <tt>:remote_options</tt> Hash of options for the link_to_remote function.
    # Default is {:method => :post, :url => rate_rateablemodel_path(rateable)}.
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
    def ratings_for(rateable, *args)
      user = extract_options(rateable, *args)
      ajaxful_styles << %Q(
      .#{options[:class]} { width: #{rateable.class.max_rate_value * 25}px; }
      .#{options[:small_star_class]} { width: #{rateable.class.max_rate_value * 10}px; }
      )
      width = (rateable.rate_average / rateable.class.max_rate_value.to_f) * 100
      content_tag(:div, :id => "ajaxful-rating-#{rateable.class.name.downcase}-#{rateable.id}") do
        content_tag(:ul, options[:html]) do
          Range.new(1, rateable.class.max_rate_value).collect do |i|
            build_star rateable, user, i
          end.insert(0, content_tag(:li, options[:current] %[rateable.rate_average, rateable.class.max_rate_value],
              :class => 'current-rating', :style => "width:#{width}%"))
        end
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
      stylesheet_link_tag('ajaxful_rating') + content_tag(:style, ajaxful_styles, :type => 'text/css') unless ajaxful_styles.blank?
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
      star_options = {:class => a_class, :title => pluralize_title(i, rateable.class.max_rate_value)}
      star = if user && ((rateable.rated_by?(user) && rateable.class.options[:allow_update]) || !rateable.rated_by?(user))
        link_to_remote(i, build_remote_options(star_options, i))
      else
        content_tag(:span, i, star_options)
      end
      content_tag(:li, star)
    end
  
    # Default options for the helper.
    def options
      @options ||= {
        :class => 'ajaxful-rating',
        :link_class_prefix => :stars,
        :title_singular => "1 star out of %d",
        :title_plural => "%d stars out of %d",
        :current => "Currently %d/%d stars",
        :small_stars => false,
        :small_star_class => 'small-star',
        :html => {},
        :remote_options => {:method => :post}
      }
    end
  
    # Builds the proper title for the star.
    def pluralize_title(current, max)
      (current == 1) ? options[:title_singular] % max : options[:title_plural] % [current, max]
    end
  
    # Temporary instance to hold dynamic styles.
    def ajaxful_styles
      @ajaxful_styles ||= ''
    end
  
    # Builds the default options for the link_to_remote function.
    def build_remote_options(html, i)
      options[:remote_options].reverse_merge(:html => html).merge(:url => "#{options[:remote_options][:url]}?#{{:stars => i}.to_query}")
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
