require "bundler/gem_tasks"
require 'rake/testtask'

test = File.expand_path('../test', __FILE__)
$LOAD_PATH.unshift(test) unless $LOAD_PATH.include?(test)

task default: :test

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
  t.warning = true
end

task :migrate do
  require 'active_record'
  c = ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
  # c.connection.drop_table 'cars'
  ActiveRecord::Migrator.migrations_paths << File.expand_path('../test/db/migrate', __FILE__)
  require 'schema'

  require 'blueprint'
  Blueprint.config do |c|
    c.eager_load       = true
    c.eager_load_paths += ['models/**/*.rb']
    c.migration_path   = File.expand_path("../test/db/migrate", __FILE__)
  end

  Blueprint::Migrator.interactive
end
