require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

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
  c = ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
  # c.connection.drop_table 'cars'
  ActiveRecord::Migrator.migrations_paths << File.expand_path('../test/db/migrate', __FILE__)
  require 'schema'

  require 'blueprint'
  Blueprint.config do |c|
    c.eager_load       = true
    c.eager_load_paths += ['models/**/*.rb']
    c.migration_path   = File.expand_path('../test/db/migrate', __FILE__)
  end

  Blueprint::Migrator.interactive
end

namespace :analysis do
  RuboCop::RakeTask.new

  desc 'Analyze code style'
  task style: [:rubocop]

  desc 'Analyze code duplication'
  task :duplication do
    output = `bundle exec flay lib/`
    if output.include? 'Similar code found'
      puts output
      exit 1
    end
  end

  desc 'Analyze code complexity'
  task :comlexity do
    output = `bundle exec flog -m lib/`
    exit_code = 0
    minimum_score = 30
    output = output.lines

    # Skip total and average complexity score
    output.shift
    output.shift

    output.each do |line|
      score, method = line.split(' ')
      score = score.to_i

      if score > minimum_score
        exit_code = 1
        puts "High complexity in #{method}. Score: #{score}"
      end
    end

    exit exit_code
  end
end
