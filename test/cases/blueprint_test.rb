require 'test_helper'

class WhiteprintTest < ActiveSupport::TestCase
  def setup
    @model     = Class.new
    @whiteprint = ::Whiteprint::Base.new(@model)
  end

  test 'a whiteprint is tied to a model' do
    assert_equal @model, @whiteprint.model
  end

  test 'a whiteprint is initialized with an empty set of attributes' do
    assert_equal({}, @whiteprint.attributes.to_h)
  end

  test 'a whiteprint saves attributes with a type and options' do
    @whiteprint.string  :name, default: 'John'
    @whiteprint.integer 'age'

    assert_equal({ name: :name, type: :string,  default: 'John' }, @whiteprint.attributes.name.to_h)
    assert_equal({ name: :age,  type: :integer },                  @whiteprint.attributes.age.to_h)
  end

  test 'attributes can be accessed like a hash with indifferent access, but they can also be accessed as methods' do
    @whiteprint.string :name, default: 'John'

    assert_equal :string, @whiteprint.attributes['name'][:type]
    assert_equal :string, @whiteprint.attributes.name.type
    assert_equal 'John',  @whiteprint.attributes[:name]['default']
    assert_equal 'John',  @whiteprint.attributes.name.default
  end
end

class WhiteprintModelTest < ActiveSupport::TestCase
  test 'a model responds to whiteprint (and schema) if Whiteprint::Model is included' do
    model = Class.new do
      include Whiteprint::Model
    end
    assert_respond_to model, :whiteprint
    assert_respond_to model, :schema
  end

  test 'if a model inherits from ActiveRecord::Base has_whiteprint does the same as including Whiteprint::Model' do
    model = Class.new(ActiveRecord::Base) do
      has_whiteprint
    end

    assert model < Whiteprint::Model
  end

  test 'a model can add attribtues to its whiteprint by passing the whiteprint method a block' do
    model = Class.new do
      include Whiteprint::Model

      whiteprint do
        string  :name, default: 'John'
        integer :age
      end
    end

    assert_instance_of ::Whiteprint::Base, model.whiteprint
    assert_equal({ name: :name, type: :string,  default: 'John' }, model.whiteprint.attributes.name.to_h)
    assert_equal({ name: :age,  type: :integer },                  model.whiteprint.attributes.age.to_h)
  end

  test "attributes can also be added to a model's whiteprint via composition" do
    concern = Module.new do
      extend ActiveSupport::Concern
      include Whiteprint::Model

      included do
        whiteprint do
          string  :name, default: 'John'
        end
      end
    end

    model = Class.new do
      include Whiteprint::Model
      include concern

      whiteprint do
        integer :age
      end
    end

    assert_equal({ name: :name, type: :string,  default: 'John' }, model.whiteprint.attributes.name.to_h)
    assert_equal({ name: :age,  type: :integer },                  model.whiteprint.attributes.age.to_h)
  end

  test 'an adapter can be set by the user or is automatically determined if possible' do
    model = Class.new do
      include Whiteprint::Model

      whiteprint(adapter: :active_record) do
      end
    end

    assert_instance_of ::Whiteprint::Adapters::ActiveRecord, model.whiteprint

    model = Class.new(ActiveRecord::Base) do
      include Whiteprint::Model

      whiteprint do
      end
    end

    assert_instance_of ::Whiteprint::Adapters::ActiveRecord, model.whiteprint

    model = Class.new(ActiveRecord::Base) do
      include Whiteprint::Model

      whiteprint(adapter: :base) do
      end
    end

    assert_instance_of ::Whiteprint::Base, model.whiteprint
  end

  def teardown
    Whiteprint.models = []
    Whiteprint::Migrator.eager_load!
  end
end
