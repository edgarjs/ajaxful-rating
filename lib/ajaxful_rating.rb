module Mimbles # :nodoc:
  module AjaxfulRating # :nodoc:
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      
      # Makes the necesary associations for the model to be rateable.
      # And prepares some useful class/instance methods.
      def has_ajaxful_rates
        has_many :rates, :as => :rateable, :dependent => :destroy
        
        include Mimbles::AjaxfulRating::InstanceMethods
        extend Mimbles::AjaxfulRating::SingletonMethods
      end
      
      # Makes the association between user and rate models.
      def is_ajaxful_rater
        has_many :rates
      end
      
      # Name for the cached average column in the rateable model.
      def cached_average_column
        "rating_average"
      end
      
      # Set the name for the cached average column in the rateable model.
      def set_cached_average_column(value = nil, &block)
        define_attr_method :cached_average_column, value, &block
      end
    end
    
    # Instance methods for the rateable object.
    module InstanceMethods
      
      # Submits a new rate
      def rate(stars, user)
        return false if stars.to_i > self.class.stars
        
        rate = Rate.new(:rate => stars)
        rate.rateable_type = self.class.name
        if (rates << rate) && (user.rates << rate)
          self.update_cached_average
        end
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
        rates.sum(:rate)
      end
      
      # Rating average for the object.
      def rate_average(cached = true)
        avg = if cached && self.class.caching_average?
          self[self.class.cached_average_column]
        else
          self.rates_sum.to_f / self.total_rates.to_f
        end.to_f
        avg.nan? ? 0.0 : avg
      end
      
      # Updates the cached average column in the rateable model.
      def update_cached_average
        if self.class.caching_average?
          self.update_attribute(self.class.cached_average_column, self.rate_average(false))
        end
      end
    end
    
    # Class methods for the rateable model.
    module SingletonMethods
      define_method(:stars) { 5 } unless respond_to?(:stars)
      
      # Finds all rateable objects rated by the +user+.
      def find_rated_by(user)
        find_statement(:user_id, user.id)
      end
      
      # Finds all rateable objects rated with +stars+.
      def find_rated_with(stars)
        find_statement(:rate, stars)
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
      # default null and as decimal:
      # 
      #   t.decimal :rating_average, :precision => 3, :scale => 1, :default => nil
      # 
      # To customize the name of the column see Mimbles::AjaxfulRating::ClassMethods.set_cached_average_column
      def caching_average?
        column_names.include?(cached_average_column)
      end
    end
  end
end