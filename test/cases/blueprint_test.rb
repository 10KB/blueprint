require 'test_helper'

class BlueprintTest < ActiveSupport::TestCase
  def setup
    @model     = Class.new
    @blueprint = ::Blueprint::Base.new(@model)
  end

  test 'a blueprint is tied to a model' do
    assert_equal @model, @blueprint.model
  end

  test 'a blueprint is initialized with an empty set of attributes' do
    assert_equal({}, @blueprint.attributes.to_h)
  end

  test 'a blueprint saves attributes with a type and options' do
    @blueprint.string  :name, {default: 'John'}
    @blueprint.integer 'age'

    assert_equal({name: :name, type: :string,  default: 'John'}, @blueprint.attributes.name.to_h)
    assert_equal({name: :age,  type: :integer},                  @blueprint.attributes.age.to_h)
  end

  test 'attributes can be accessed like a hash with indifferent access, but they can also be accessed as methods' do
    @blueprint.string  :name, {default: 'John'}

    assert_equal :string, @blueprint.attributes['name'][:type]
    assert_equal :string, @blueprint.attributes.name.type
    assert_equal 'John',  @blueprint.attributes[:name]['default']
    assert_equal 'John',  @blueprint.attributes.name.default
  end
end

class BlueprintModelTest < ActiveSupport::TestCase
  test 'a model responds to blueprint (and schema) if Blueprint::Model is included' do
    model = Class.new do
      include Blueprint::Model
    end
    assert_respond_to model, :blueprint
    assert_respond_to model, :schema
  end

  test 'if a model inherits from ActiveRecord::Base has_blueprint does the same as including Blueprint::Model' do
    model = Class.new(ActiveRecord::Base) do
      has_blueprint
    end

    assert model < Blueprint::Model
  end

  test 'a model can add attribtues to its blueprint by passing the blueprint method a block' do
    model = Class.new do
      include Blueprint::Model

      blueprint do
        string  :name, default: 'John'
        integer :age
      end
    end

    assert_instance_of ::Blueprint::Base, model.blueprint
    assert_equal({name: :name, type: :string,  default: 'John'}, model.blueprint.attributes.name.to_h)
    assert_equal({name: :age,  type: :integer},                  model.blueprint.attributes.age.to_h)
  end


  test "attributes can also be added to a model's blueprint via composition" do
    concern = Module.new do
      extend ActiveSupport::Concern
      include Blueprint::Model

      included do
        blueprint do
          string  :name, default: 'John'
        end
      end
    end

    model = Class.new do
      include Blueprint::Model
      include concern

      blueprint do
        integer :age
      end
    end

    assert_equal({name: :name, type: :string,  default: 'John'}, model.blueprint.attributes.name.to_h)
    assert_equal({name: :age,  type: :integer},                  model.blueprint.attributes.age.to_h)
  end

  test 'an adapter can be set by the user or is automatically determined if possible' do
    model = Class.new do
      include Blueprint::Model

      blueprint(adapter: :active_record) do
      end
    end

    assert_instance_of ::Blueprint::Adapters::ActiveRecord, model.blueprint

    model = Class.new(ActiveRecord::Base) do
      include Blueprint::Model

      blueprint do
      end
    end

    assert_instance_of ::Blueprint::Adapters::ActiveRecord, model.blueprint

    model = Class.new(ActiveRecord::Base) do
      include Blueprint::Model

      blueprint(adapter: :base) do
      end
    end

    assert_instance_of ::Blueprint::Base, model.blueprint
  end
end
