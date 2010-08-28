# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ajaxful_rating}
  s.version = "2.2.8.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Edgar J. Suarez"]
  s.date = %q{2010-08-27}
  s.description = %q{Provides a simple way to add rating functionality to your application.}
  s.email = %q{edgar.js@gmail.com}
  s.extra_rdoc_files = ["CHANGELOG", "README.textile", "lib/ajaxful_rating.rb", "lib/axr/css_builder.rb", "lib/axr/errors.rb", "lib/axr/helpers.rb", "lib/axr/locale.rb", "lib/axr/model.rb", "lib/axr/stars_builder.rb"]
  s.files = ["CHANGELOG", "Manifest", "README.textile", "Rakefile", "ajaxful_rating.gemspec", "generators/ajaxful_rating/USAGE", "generators/ajaxful_rating/ajaxful_rating_generator.rb", "generators/ajaxful_rating/templates/images/star.png", "generators/ajaxful_rating/templates/images/star_small.png", "generators/ajaxful_rating/templates/migration.rb", "generators/ajaxful_rating/templates/model.rb", "generators/ajaxful_rating/templates/style.css", "init.rb", "lib/ajaxful_rating.rb", "lib/axr/css_builder.rb", "lib/axr/errors.rb", "lib/axr/helpers.rb", "lib/axr/locale.rb", "lib/axr/model.rb", "lib/axr/stars_builder.rb"]
  s.homepage = %q{http://github.com/edgarjs/ajaxful-rating}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Ajaxful_rating", "--main", "README.textile"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ajaxful_rating}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Provides a simple way to add rating functionality to your application.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
