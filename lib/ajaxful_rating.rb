module AjaxfulRating # :nodoc:
  class DependencyError < StandardError; end
  
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    # Extends the model to be easy ajaxly rateable.
    #
    # Options:
    # * <tt>:stars</tt> Max number of stars that can be submitted.
    # * <tt>:once</tt> Set to true if the model can be rated multiple times by the same user.
    # It will *update* the user previous rating, not create a new one.
    # * <tt>:cache_column</tt> Name of the column for storing the cached rating average.
    # * <tt>:logged_in_user_instance</tt> Name of the instance for the current logged in user.
    # 
    # Example:
    #   class Article < ActiveRecord::Base
    #     ajaxful_rateable :stars => 10, :cache_column => :custom_column
    #   end
    def ajaxful_rateable(options = {})
      has_many :rates, :as => :rateable, :dependent => :destroy
      
      self.options.merge!(options)
      include AjaxfulRating::InstanceMethods
      extend AjaxfulRating::SingletonMethods
    end

    # Makes the association between user and Rate model.
    def ajaxful_rater(options = {})
      has_many :rates, options
    end
    
    # Maximum value accepted when rating the model. Default is 5.
    # 
    # Change it by passing the :stars option to +ajaxful_rateable+
    # 
    #   ajaxful_rateable :stars => 10
    def max_rate_value
      options[:stars]
    end
    
    # Default options for rating.
    def options
      {
        :stars => 5,
        :once => false,
        :cache_column => :rating_average
      }
    end
  end

  # Instance methods for the rateable object.
  module InstanceMethods

    # Submits a new rate. Accepts a hash of tipical Ajax request.
    # 
    # Example:
    #   # Articles Controller
    #   def rate
    #     @article = Article.find(params[:id])
    #     @article.rate(params[:stars], current_user)
    #     # some page update here ...
    #   end
    def rate(stars, user)
      return false if stars > self.class.max_rate_value

      rate = rates.build(:stars => stars)
      if user.respond_to?(:rates)
        user.rates << rate
      else
        rate.user_id = user.id
        rate.save!
      end
      self.update_cached_average
    end

    # Returns an array with all users that have rated this object.
    def rated_by
      User.find_by_sql(["SELECT u.* FROM users u INNER JOIN rates r ON u.[id] = r.[user_id] " +
            "WHERE r.[rateable_id] = ? AND r.[rateable_type] = ?", id, self.class.name]).uniq
    end

    # Return true if the user has rated the object, otherwise false
    def rated_by?(user)
      !rates.find_by_user_id(user).nil?
    end

    # Object's total rates.
    def total_rates
      rates.size
    end

    # Total sum of the rates.
    def rates_sum
      rates.sum(:stars)
    end

    # Rating average for the object.
    def rate_average(cached = true)
      avg = if cached && self.class.caching_average?
        self[self.class.options[:cache_column]]
      else
        self.rates_sum.to_f / self.total_rates.to_f
      end.to_f
      avg.nan? ? 0.0 : avg
    end

    # Updates the cached average column in the rateable model.
    def update_cached_average
      if self.class.caching_average?
        self.update_attribute(self.class.options[:cache_column], self.rate_average(false))
      end
    end
  end

  # Class methods for the rateable model.
  module SingletonMethods

    # Finds all rateable objects rated by the +user+.
    def find_rated_by(user)
      find_statement(:user_id, user.id)
    end

    # Finds all rateable objects rated with +stars+.
    def find_rated_with(stars)
      find_statement(:stars, stars)
    end

    # Finds the rateable object with the highest rate average.
    def find_most_popular
      find(:all).sort {|r1, r2| r1.rate_average <=> r2.rate_average}.last
    end

    # Finds the rateable object with the lowest rate average.
    def find_less_popular
      find(:all).sort {|r1, r2| r1.rate_average <=> r2.rate_average}.first
    end

    # Finds rateable objects by Rate's attribute.
    def find_statement(attr_name, attr_value)
      rateable = self.base_class.name
      sql = sanitize_sql(["SELECT DISTINCT r2.* FROM rates r1 INNER JOIN " +
            "#{rateable.constantize.table_name} r2 ON r1.rateable_id = r2.id " +
            "WHERE (r1.[rateable_type] = ? AND r1.[#{attr_name}] = ?)",
          rateable, attr_value])
      find_by_sql(sql)
    end

    # Indicates if the rateable model is able to cache the rate average.
    #
    # Include a column named +rating_average+ in your rateable model with
    # default null, as decimal:
    #
    #   t.decimal :rating_average, :precision => 3, :scale => 1, :default => nil
    #
    # To customize the name of the column specify the option <tt>:cache_column</tt> to ajaxful_rateable
    # 
    #   ajaxful_rateable :cache_column => :my_custom_column
    #
    def caching_average?
      column_names.include?(options[:cache_column])
    end
  end
end
