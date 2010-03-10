module AjaxfulRating # :nodoc:
  module Helpers
    include AjaxfulRating::Errors
    
    # Outputs the required css file, and the dynamic CSS generated for the
    # current page.
    def ajaxful_rating_style
      @axr_css ||= CSSBuilder.new
      stylesheet_link_tag('ajaxful_rating') +
        content_tag(:style, @axr_css.to_css, :type => "text/css")
    end
    
    # Generates the stars list to submit a rate.
    # 
    # It accepts the next options:
    # * <tt>:small</tt> Set this param to true to display smaller images. Default is false.
    # * <tt>:remote_options</tt> Hash of options for the link_to_remote function.
    # Default is {:method => :post, :url => rate_rateablemodel_path(rateable)}.
    # * <tt>:wrap</tt> Whether the star list is wrapped within a div tag or not. This is useful when page updating. Default is true.
    # * <tt>:show_user_rating</tt> Set to true if you want to display only the current user's rating, instead of the global average.
    # * <tt>:dimension</tt> The dimension to show the ratings for.
    # * <tt>:force_static</tt> Force static stars even when you're passing a user instance.
    # 
    # Example:
    #   <%= ratings_for @article, :wrap => false %> # => Will produce something like:
    #   <ul class="ajaxful-rating">
    #     <li class="current-rating" style="width: 60%;">3</li>
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
    #   <%= ratings_for @article, @user, :small => true %>
    #   # => Will use @user instead <tt>current_user</tt>
    #   
    #   <%= ratings_for @article, :static, :small => true %>
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
    # By default ratings_for will render the average rating for all users. If however you would like to display the rating for a single user, then set the :show_user_rating option to true.
    # For example:
    #
    #   <%= ratings_for @article, :show_user_rating => true %>
    # Or
    #   <%= ratings_for @article, @user, :show_user_rating => true %>
    #
    # I18n:
    # 
    # You can translate the title of the images (the tool tip that shows when the mouse is over) and the 'Currently x/x stars'
    # string by setting these keys on your translation hash:
    # 
    #   ajaxful_rating:
    #     helper:
    #       global_average: "Global rating average: {{value}} out of {{max}}"
    #       user_rating: "Your rating: {{value}} out of {{max}}"
    #       hover: "Rate {{value}} out of {{max}}"    def ratings_for(*args)
    def ratings_for(*args)
      @axr_css ||= CSSBuilder.new
      options = args.extract_options!.symbolize_keys.slice(:small, :remote_options,
        :wrap, :show_user_rating, :dimension, :force_static, :current_user)
      remote_options = options.delete(:remote_options) || {}
      rateable = args.shift
      user = args.shift || (respond_to?(:current_user) ? current_user : raise(NoUserSpecified))
      StarsBuilder.new(rateable, user, self, @axr_css, options, remote_options).render
    end
  end
end

class ActionView::Base # :nodoc:
  include AjaxfulRating::Helpers
end
