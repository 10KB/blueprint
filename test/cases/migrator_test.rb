require 'test_helper'

if ActiveSupport::TestCase.respond_to?(:test_order=)
  # TODO: remove check once ActiveSupport dependency is at least 4.2
  ActiveSupport::TestCase.test_order = :random
end

class MigratorTest < ActiveSupport::TestCase
  def setup
    Blueprint.config do |c|
      c.eager_load       = true
      c.eager_load_paths += ['models/**/*.rb']
      c.migration_path   = File.expand_path("../../db/migrate", __FILE__)
    end
  end

  test "models can be eager loaded by blueprint" do
    Object.send :remove_const, :Car
    Object.send :remove_const, :User

    assert_raises(NameError) { Car }
    assert_raises(NameError) { User }

    Blueprint::Migrator.eager_load!

    assert_includes Blueprint.models, Car
    assert_includes Blueprint.models, User
  end

  test "blueprint can write all changes to migration" do
    expected_migration = <<-RUBY
class TestMigration < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.change :name, :string, {:default=>"Joe"}
      t.change :age, :integer, {:default=>10}
      t.remove :date_of_birth
    end

    create_table :cars do |t|
      t.string :brand, {:default=>"BMW"}
      t.decimal :price, {:precision=>5, :scale=>10}
      t.timestamps
    end
  end
end
    RUBY

    input = StringIO.new
    input << '1' << "\n"
    input.rewind

    migrate_input = StringIO.new
    migrate_input << "test migration" << "\n"
    migrate_input.rewind

    Blueprint::Migrator.interactive input: input, migrate_input: migrate_input

    migration = File.read(Dir.glob('test/db/migrate/*_test_migration.rb').first)

    assert_equal expected_migration, migration
  end

  def teardown
    path = Dir.glob('test/db/migrate/*_test_migration.rb').first
    File.delete(path) if path
  end
end
