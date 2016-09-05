require 'test_helper'

class ChangesTreeTest < ActiveSupport::TestCase
  def setup
    @model = Class.new do
      include Blueprint::Model

      blueprint(adapter: :test) do
        string  :name,  default: 'John'
        integer :age,   default: 0
        date    :date_of_birth

        persisted do
          string  :name
          integer :age,   default: 0
          integer :weight
        end
      end

      def self.table_name
        'persons'
      end

      def self.table_exists?
        true
      end
    end
  end

  test 'the test adapter can set its persisted attributes with a block' do
    assert_equal Blueprint::Attribute.new(name: :name, type: :string),             @model.blueprint.persisted_attributes.name
    assert_equal Blueprint::Attribute.new(name: :age, type: :integer, default: 0), @model.blueprint.persisted_attributes.age
    assert_equal Blueprint::Attribute.new(name: :weight, type: :integer),          @model.blueprint.persisted_attributes.weight
  end

  test 'a blueprint can generate a changes_tree with all the differences between the persisted attributes and the actual attributes' do
    changes_tree = @model.blueprint.changes_tree

    attributes = [
      { name: :date_of_birth, type: :date, options: {}, kind: :added },
      { name: :name, type: :string, options: { default: 'John' }, kind: :changed },
      { name: :weight, type: :integer, options: {}, kind: :removed }
    ]
    assert_equal({ table_name: 'persons', table_exists: true, attributes: attributes }, changes_tree)
  end

  def teardown
    Blueprint.models = []
    Blueprint::Migrator.eager_load!
  end
end
