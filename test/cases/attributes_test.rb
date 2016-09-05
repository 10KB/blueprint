require 'test_helper'

class AttributesTest < ActiveSupport::TestCase
  def setup
    @attribute  = Whiteprint::Attribute.new type: :integer, default: 10

    @attributes = Whiteprint::Attributes.new

    @attributes.add name: 'name',           type: :string,  default: 'John'
    @attributes.add name: 'age',            type: :integer
    @attributes.add name: 'height',         type: :integer, default: 180
    @attributes.add name: 'date_of_birth',  type: :date
  end

  test 'an attribute can be asked whether it has a certain key or keys' do
    assert_equal true,  @attribute.has?(:type)
    assert_equal true,  @attribute.has?(:type, :default)
    assert_equal false, @attribute.has?(:type, :foo)
  end

  test 'an attribute can be asked whether it has a certain values' do
    assert_equal true,  @attribute.has?(type: :integer)
    assert_equal false, @attribute.has?(type: :string)
    assert_equal true,  @attribute.has?(type: :integer, default: 10)
    assert_equal true,  @attribute.has?(:type, default: 10)
    assert_equal false, @attribute.has?(:type, default: 11)
  end

  test 'attributes can be queried' do
    assert_equal @attributes.to_h.slice(:name, :height),        @attributes.where(:default).to_h
    assert_equal @attributes.to_h.slice(:name),                 @attributes.where(default: 'John').to_h
    assert_equal @attributes.to_h.slice(:age, :height),         @attributes.where(type: :integer).to_h
    assert_equal @attributes.to_h.slice(:name, :date_of_birth), @attributes.not(type: :integer).to_h
    assert_equal @attributes.to_h.slice(:name),                 @attributes.where(:default).not(type: :integer).to_h
  end

  test 'attributes can be diffed' do
    diff = @attributes.where(:default).diff(@attributes)

    assert_equal @attributes.to_h.slice(:age, :date_of_birth), diff[:added].to_h
    assert_equal({},                                           diff[:removed].to_h)
    assert_equal({},                                           diff[:changed].to_h)

    diff = @attributes.diff(@attributes.where(:default))

    assert_equal({},                                           diff[:added].to_h)
    assert_equal @attributes.to_h.slice(:age, :date_of_birth), diff[:removed].to_h
    assert_equal({},                                           diff[:changed].to_h)

    diff_attributes = Whiteprint::Attributes.new

    diff_attributes.add name: 'name',           type: :string,  default: 'Joe'
    diff_attributes.add name: 'weight',         type: :integer
    diff_attributes.add name: 'height',         type: :integer, default: 160

    diff = @attributes.diff(diff_attributes)

    assert_equal diff_attributes.to_h.slice(:weight),          diff[:added].to_h
    assert_equal @attributes.to_h.slice(:age, :date_of_birth), diff[:removed].to_h
    assert_equal diff_attributes.to_h.slice(:name, :height),   diff[:changed].to_h
  end
end
