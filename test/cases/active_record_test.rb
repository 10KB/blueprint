require 'test_helper'

class ActiveRecordTest < ActiveSupport::TestCase
  def setup
    @persisted_attributes = User.blueprint.persisted_attributes
  end

  test "the active_record adapter can read the persisted attributes from the database" do
    assert_equal Blueprint::Attribute.new(name: :name, type: :string, default: 'John').to_persisted,   @persisted_attributes.name
    assert_equal Blueprint::Attribute.new(name: :age, type: :integer, default: 0).to_persisted,        @persisted_attributes.age
    assert_equal Blueprint::Attribute.new(name: :date_of_birth, type: :date).to_persisted,             @persisted_attributes.date_of_birth
  end
end
