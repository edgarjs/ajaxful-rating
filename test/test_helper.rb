$:.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'test/unit'
require 'active_record'
require 'active_record/fixtures'
require 'action_controller'
require 'ajaxful_rating'

AXR_FIXTURES_PATH = File.join(File.dirname(__FILE__), 'fixtures')

# For transactional fixtures to work in tests, configurations in AR::Base has to be set to something
ActiveRecord::Base.configurations = {:epic => 'fail'}
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

# Add fixtures to load path
dep = defined?(ActiveSupport::Dependencies) ? ActiveSupport::Dependencies : ::Dependencies
dep.load_paths.unshift AXR_FIXTURES_PATH

ActiveRecord::Base.silence do
  ActiveRecord::Migration.verbose = false
  load File.join(AXR_FIXTURES_PATH, 'schema.rb')
end

Fixtures.create_fixtures(AXR_FIXTURES_PATH, ActiveRecord::Base.connection.tables)