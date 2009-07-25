# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ajaxful_rating}
  s.version = "2.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Edgar J. Suarez"]
  s.date = %q{2009-07-25}
  s.description = %q{Provides a simple way to add rating functionality to your application.}
  s.email = %q{e@dgar.org}
  s.extra_rdoc_files = ["CHANGELOG", "lib/ajaxful_rating.rb", "lib/ajaxful_rating_helper.rb", "lib/ajaxful_rating_model.rb", "README.textile"]
  s.files = ["CHANGELOG", "generators/ajaxful_rating/ajaxful_rating_generator.rb", "generators/ajaxful_rating/templates/images/star.png", "generators/ajaxful_rating/templates/images/star_small.png", "generators/ajaxful_rating/templates/migration.rb", "generators/ajaxful_rating/templates/model.rb", "generators/ajaxful_rating/templates/style.css", "generators/ajaxful_rating/USAGE", "init.rb", "lib/ajaxful_rating.rb", "lib/ajaxful_rating_helper.rb", "lib/ajaxful_rating_model.rb", "Manifest", "Rakefile", "README.textile", "ajaxful_rating.gemspec"]
  s.homepage = %q{http://github.com/edgarjs/ajaxful-rating}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Ajaxful_rating", "--main", "README.textile"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ajaxful_rating}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Provides a simple way to add rating functionality to your application.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
