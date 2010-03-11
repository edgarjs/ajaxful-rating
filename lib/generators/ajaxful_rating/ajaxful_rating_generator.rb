require 'rails/generators/migration'
class AjaxfulRatingGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration
  
  def self.source_root
    @_axr_root ||= File.expand_path("../templates", __FILE__)
  end

  def create_model_files
    model_file = File.join('app/models', "#{file_path}.rb")
    raise "User model (#{model_file}) must exits." unless File.exists?(model_file)
    class_collisions 'Rate'
    template 'model.rb', File.join('app/models', class_path, "rate.rb")
  end

  def create_migration
    migration_template 'migration.rb', "db/migrate/create_rates.rb"
  end

  def create_layout
    copy_file 'images/star.png', 'public/images/ajaxful_rating/star.png'
    copy_file 'images/star_small.png', 'public/images/ajaxful_rating/star_small.png'
    copy_file 'style.css', 'public/stylesheets/ajaxful_rating.css'
  end

  private

  # FIXME: Should be proxied to ActiveRecord::Generators::Base
  # Implement the required interface for Rails::Generators::Migration.
  def self.next_migration_number(dirname) #:nodoc:
    if ActiveRecord::Base.timestamped_migrations
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    else
      "%.3d" % (current_migration_number(dirname) + 1)
    end
  end

end
