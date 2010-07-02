module AjaxfulRating # :nodoc:
  class StarsBuilder # :nodoc:
    include AjaxfulRating::Locale
    
    attr_reader :rateable, :user, :options, :remote_options
    
    def initialize(rateable, user_or_static, template, css_builder, options = {}, remote_options = {})
      @user = user_or_static unless user_or_static == :static
      @rateable, @template, @css_builder = rateable, template, css_builder
      apply_stars_builder_options!(options, remote_options)
    end
    
    def show_value
      if options[:show_user_rating]
        rate = rateable.rate_by(user, options[:dimension]) if user
        rate ? rate.stars : 0
      else
        rateable.rate_average(true, options[:dimension])
      end
    end
    
    def render
      options[:wrap] ? wrapper_tag : ratings_tag
    end
    
    private
    
    def apply_stars_builder_options!(options, remote_options)
      @options = {
        :wrap => true,
        :small => false,
        :show_user_rating => false,
        :force_static => false,
        :current_user => (@template.current_user if @template.respond_to?(:current_user))
      }.merge(options)
      
      @options[:small] = @options[:small].to_s == 'true'
      @options[:show_user_rating] = @options[:show_user_rating].to_s == 'true'
      @options[:wrap] = @options[:wrap].to_s == 'true'
      
      @remote_options = {
        :url => nil,
        :method => :post
      }.merge(remote_options)
      
      if @remote_options[:url].nil?
        rateable_name = ActionController::RecordIdentifier.singular_class_name(rateable)
        url = "rate_#{rateable_name}_path"
        if @template.respond_to?(url)
          @remote_options[:url] = @template.send(url, rateable)
        else
          raise(MissingRateRoute)
        end
      end
    end
    
    def ratings_tag
      stars = []
      width = (show_value / rateable.class.max_stars.to_f) * 100
      li_class = "axr-#{show_value}-#{rateable.class.max_stars}".gsub('.', '_')
      @css_builder.rule('.ajaxful-rating', :width => (rateable.class.max_stars * 25))
      @css_builder.rule('.ajaxful-rating.small',
        :width => (rateable.class.max_stars * 10)) if options[:small]
      
      stars << @template.content_tag(:li, i18n(:current), :class => "show-value",
        :style => "width: #{width}%")
      stars += (1..rateable.class.max_stars).map do |i|
        star_tag(i)
      end
      # When using rails_xss plugin, it needs to render as HTML
      stars = "".respond_to?(:html_safe) ? stars.join.html_safe : stars.join
      @template.content_tag(:ul, stars, :class => "ajaxful-rating#{' small' if options[:small]}")
    end
    
    def star_tag(value)
      already_rated = rateable.rated_by?(user, options[:dimension]) if user
      css_class = "stars-#{value}"
      @css_builder.rule(".ajaxful-rating .#{css_class}", {
        :width => "#{(value / rateable.class.max_stars.to_f) * 100}%",
        :zIndex => (rateable.class.max_stars + 2 - value).to_s
      })
      @template.content_tag(:li) do
        if !options[:force_static] && (user && options[:current_user] == user &&
          (!already_rated || rateable.axr_config[:allow_update]))
          link_star_tag(value, css_class)
        else
          @template.content_tag(:span, show_value, :class => css_class, :title => i18n(:current))
        end
      end
    end
    
    def link_star_tag(value, css_class)
      query = {
        :stars => value,
        :dimension => options[:dimension],
        :small => options[:small],
        :show_user_rating => options[:show_user_rating]
      }.to_query
      config = {
        :html => {
          :class => css_class,
          :title => i18n(:hover, value)
        },
        :url => "#{remote_options[:url]}",
        :with => "'#{query}'"
      }
      @template.link_to_remote(value, remote_options.merge(config))
    end
    
    def wrapper_tag
      @template.content_tag(:div, ratings_tag, :class => "ajaxful-rating-wrapper",
        :id => rateable.wrapper_dom_id(options))
    end
  end
end
