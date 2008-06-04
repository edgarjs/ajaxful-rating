class AjaxfulRatingGenerator < Rails::Generator::Base
  def manifest
    rails2_0 = RAILS_GEM_VERSION =~ /2\.0\.\d/
    
    record do |m|
      m.file 'rate_model.rb', 'app/models/rate.rb'
      m.migration_template "#{rails2_0 ? 'rails2' : 'rails1'}_migration.rb", 'db/migrate',
        :migration_file_name => 'create_rates'
      m.directory 'public/images/ajaxful_rating'
      m.file 'images/star_off.gif', 'public/images/ajaxful_rating/star_off.gif'
      m.file 'images/star_on.gif', 'public/images/ajaxful_rating/star_on.gif'
      m.file 'images/star_hover.gif', 'public/images/ajaxful_rating/star_hover.gif'
      m.file 'images/blank.gif', 'public/images/ajaxful_rating/blank.gif'
      m.file 'style.css', 'public/stylesheets/ajaxful_rating.css'
    end
  end
end
