# Whiteprint
by [10KB](https://10kb.nl)


Whiteprint keeps track of the attributes of your models. It:
* Generates migrations for you if you update your model's whiteprint (only ActiveRecord at the moment)
* Provides you with helpers to use in your serializers or permitted attributes definition
* Can be extended with plugins
* Has support for inheritance and composition

## Installation

Add this line to your application's Gemfile:

    gem 'whiteprint'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install whiteprint

## Usage

### 1. Add Whiteprint to your model

```ruby
class Car
  include Whiteprint::Model
end
```

Alternatively, in an ActiveRecord model you could also use `has_whiteprint`.

```ruby
class Car < ActiveRecord::Base
  has_whiteprint
end
```

### 2. Add some attributes

```ruby
class Car < ActiveRecord::Base
  include Whiteprint::Model

  whiteprint do
    string  :brand, default: 'BMW'
    string  :name
    text    :description
    decimal :price, precision: 5, scale: 10
  end
end
```

### 3. Generate a migration
Let Whiteprint generate a migration to update your database schema for you (only ActiveRecord at the moment). Run:

```
rake whiteprint:migrate
```

Whiteprint will check all your models for changes and list them in your terminal. If multiple models have changes it will ask you if you want to apply these changes in one or separate migrations.

```
Whiteprint has detected 1 changes to your models.
+----------------------------+------------------------+--------------------------------------------+
|                                    1. Create a new table cars                                    |
+----------------------------+------------------------+--------------------------------------------+
| name                       | type                   | options                                    |
+----------------------------+------------------------+--------------------------------------------+
| brand                      | string                 | {:default=>"BMW"}                          |
| name                       | string                 | {}                                         |
| description                | text                   | {}                                         |
| price                      | decimal                | {:precision=>10, :scale=>5}                |
| timestamps                 |                        |                                            |
+----------------------------+------------------------+--------------------------------------------+
Migrations:
1. In one migration
2. In separate migrations
How would you like to process these changes?
> 1
How would you like to name this migration?
> Create cars
```
Your migration wil be **created** and **migrated**.

```ruby
# db/migrate/*********_create_cars.rb

class CreateCars < ActiveRecord::Migration
  def change
    create_table :cars do |t|
      t.string :brand, {:default=>"BMW"}
      t.string :name, {}
      t.text :description, {}
      t.decimal :price, {:precision=>10, :scale=>5}
      t.timestamps
    end
  end
end
```

```
== 20160905153022 CreateCars: migrating =======================================
-- create_table(:cars)
   -> 0.0081s
== 20160905153022 CreateCars: migrated (0.0082s) ==============================
```

### 4. Make some changes to your model
If we make some changes to our `Car` model and run `whiteprint:migrate` again, Whiteprint will detect these changes and create a migration to update your table.

```ruby
class Car < ActiveRecord::Base
  include Whiteprint::Model

  whiteprint do
    string     :brand, default: 'Ford'
    string     :name
    decimal    :price, precision: 10, scale: 5
    references :color
  end
end
```

```
> rake whiteprint:migrate
Whiteprint has detected 1 changes to your models.
+--------+-------------+------------+------------------+--------------------+----------------------+
|                                     1. Make changes to cars                                      |
+--------+-------------+------------+------------------+--------------------+----------------------+
| action | name        | type       | type (currently) | options            | options (currently)  |
+--------+-------------+------------+------------------+--------------------+----------------------+
| added  | color       | references |                  | {}                 |                      |
| change | brand       | string     | string           | {:default=>"Ford"} | {:default=>"BMW"}    |
| remove | description |            |                  |                    |                      |
+--------+-------------+------------+------------------+--------------------+----------------------+
Migrations:
1. In one migration
2. In separate migrations
How would you like to process these changes?
1
How would you like to name this migration?
Add color change default brand and remove description for cars
== 20160905162923 AddColorChangeDefaultBrandAndRemoveDescriptionForCars: migrating
-- change_table(:cars)
   -> 0.0032s
== 20160905162923 AddColorChangeDefaultBrandAndRemoveDescriptionForCars: migrated (0.0034s)
```

## Adapters
Whiteprint is made to be persistence layer agnostic, but at this moment only an ActiveRecord adapter is implemented. If you would like to implement an adapter for another persistence layer please contact us. We'd love to help you.

An example of a Whiteprint adapter:
```ruby
module Whiteprint
  module Adapters
    class MyOwnAdapater < ::Whiteprint::Base
      class << self
        def applicable?(model)
          # method used to automatically select an adapter for a model.
          # for example:
          model < MyOrm::Base
        end

        def generate_migration(name, trees)
          # create a migration here given a set of trees with changes
          # look at the activerecord adapter for further implementation details
        end
      end

      def persisted_attributes
        # this method has to return the current attributes of the persistance layer
        # return an instance of Whiteprint::Attributes
      end

      # The whiteprint do ... end block in your model is executed in the context of your adapter instance
      # you can add methods to add functionality to your adapter. For example:
      def address(name)
        @attributes.add name: "#{name}_street",       type: :text
        @attributes.add name: "#{name}_house_number", type: :integer
        @attributes.add name: "#{name}_city",         type: :text
      end
      # And then you could do:
      # class Company < MyOrm::Base
      #   include Whiteprint::Model
      #
      #   whiteprint do
      #     address :office
      #   end
      # end
    end
  end
end
```

## ActiveRecord Adapter
The ActiveRecord adapter has some special properties which are explained in this section.

### Default id and timestamps
By default the adapter will add id and timestamps columns. You can disable this behaviour by passing arguments to the whiteprint method.

Model without an id:
```ruby
whiteprint(id: false) do
  # ...
end
```

Model without timestamps:
```ruby
whiteprint(timestamps: false) do
  # ...
end
```

### References
Adding an references columns will automatically set a `belongs_to` association on the model. Any options for the association can be passed in the whiteprint block.

```ruby
whiteprint do
  references :fileable, polymorphic: true
end
```

You can disable this behaviour by passing `auto_belongs_to: false` to the whiteprint method.

### Has and belongs to many
The activerecord adapter has support for a has_and_belongs_to_many attribute. This won't add a column to your model's table, but instead create a join table and set the association.

```ruby
whiteprint do
  has_and_belongs_to_many :categories
end
```

`habtm` is added as an alias

### Method as default value

You can specify a symbol as the default value for an attribute for dynamic defaults.

```ruby
class Car < ActiveRecord::Base
  include Whiteprint::Model

  whiteprint do
    references :user, default: :current_user
  end

  private

  def current_user
    User.current
  end
end
```

### Accessor

You can use the accessor type to add attr_accessors to your model

```ruby
class User < ActiveRecord::Base
  include Whiteprint::Model

  whiteprint do
    text     :password_digest
    accessor :password
    accessor :password_confirmation
  end
end
```

## Attributes

The whiteprint instance of a model can be accessed using the whiteprint method: `Model.whiteprint`. The attributes of a whiteprint are available using the attributes method: `Model.whiteprint.attributes`.
These attributes are an instance of `Whiteprint::Attributes` and have several helper methods available.

### for_serializer

The for_serializer helper lists all attributes that aren't private or associations.

```ruby
class Car < ActiveRecord::Base
  include Whiteprint::Model

  whiteprint do
    string     :brand, default: 'Ford'
    string     :name
    decimal    :price, precision: 10, scale: 5, private: true
    references :color
  end
end

Car.whiteprint.attributes.for_serializer
# [:id, :created_at, :updated_at, :brand, :name]

# usage example
class CarSerializer < ActiveModel::Serializer
  attributes *Car.whiteprint.attributes.for_serializer
end
```

### for_permitted

The for_serializer helper lists all attributes that aren't private or readonly in a format suitable for Rails' strong paramters.

```ruby
class Car < ActiveRecord::Base
  include Whiteprint::Model

  whiteprint do
    string     :brand,  default: 'Ford'
    string     :name,   readonly: true
    text       :specs,  array: true
    decimal    :price,  precision: 10, scale: 5, private: true
    references :color
    habtm      :owners, class_name: 'User'
  end
end

Car.whiteprint.attributes.for_permitted
# [:id, :brand, {:specs=>[]}, :color_id, {:owner_ids=>[]}]

# usage example
def permitted_params
  params.require(:car).permit(*Car.whiteprint.attributes.for_permitted)
end
```

### for_meta

The for_meta helper lists all meta info that is specified for attributes. The `meta_attribute_options` config determines which options should be listed by this helper.

```ruby
Whiteprint.config do |c|
  c.meta_attribute_options = [:enum, :label]
end

class Car < ActiveRecord::Base
  include Whiteprint::Model

  whiteprint do
    string     :brand,  default: 'Ford', enum: {"Ford"=>"Ford", "BMW"=>"BMW", "Audi"=>"Audi"}, label: 'Merk'
    string     :name,   label: 'Naam'
    text       :specs,  array: true
    decimal    :price,  precision: 10, scale: 5, private: true
    references :color
    habtm      :owners, class_name: 'User'
  end
end

Car.whiteprint.attributes.for_meta
# {:brand=>{:enum=>{"Ford"=>"Ford", "BMW"=>"BMW", "Audi"=>"Audi"}, :label=>"Merk"}, :name=>{:label=>"Naam"}}

# example usage
render json: @car, meta: Car.whiteprint.attributes.for_meta
```

## Composability

Whiteprints are inherited and can be composed.

```ruby
class Animal
  include Whiteprint::Model

  whiteprint do
    text :name
    text :description
  end
end

module Mammal
  extend ActiveSupport::Concern

  included do
    whiteprint do
      integer :gestation_period
    end
  end
end

class Dog < Animal
  include Mammal

  whiteprint do
    string :breed
  end
end

class Cat < Animal
  include Mammal

  whiteprint do
    boolean :domestic, default: true
  end
end

Cat.whiteprint.attributes.to_a.map(&:to_h)
# [{:name=>:name, :type=>:text}, {:name=>:description, :type=>:text}, {:name=>:gestation_period, :type=>:integer}, {:name=>:domestic, :type=>:boolean, :default=>true}]

Dog.whiteprint.attributes.to_a.map(&:to_h)
#[{:name=>:name, :type=>:text}, {:name=>:description, :type=>:text}, {:name=>:gestation_period, :type=>:integer}, {:name=>:breed, :type=>:string}]
```

## Configuration

```ruby
Whiteprint.config do |c|
  # which adapter to use if none is applicable
  c.default_adapter             = :base

  # Models have to be loaded before whiteprint:migrate runs. Set to true to let Whiteprint do this for you.
  c.eager_load                  = false # default true for Rails projects

  # Define  which path(s) contain whiteprint models
  c.eager_load_paths            = []

  # Define which attribute options are persisted
  c.persisted_attribute_options = {
    array: false,
    limit: nil,
    precision: nil,
    scale: nil,
    polymorphic: false,
    null: true,
    default: nil
  }

  # Define the attribute options for the for_meta gelper
  c.meta_attribute_options      = [:enum]

  # Define if changes should be run in a single or separately migrations. One of: :ask, :separately, :together
  c.migration_strategy          = :ask

  # Define if migrations should be automatically added to git
  c.add_migration_to_git        = false
end
```

## Origin
Whiteprint is extracted from an application framework we use internally. Right now, our framework is lacking tests and documentation, but we intend to open source more parts of our framework in the future.
