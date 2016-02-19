# $LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

# require 'minitest/autorun'

require 'bundler/setup'
require 'active_support'
require 'active_support/testing/autorun'

require 'active_record'
ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
require 'schema'

require 'blueprint'

require 'models/user'

if ActiveSupport::TestCase.respond_to?(:test_order=)
  # TODO: remove check once ActiveSupport dependency is at least 4.2
  ActiveSupport::TestCase.test_order = :random
end
