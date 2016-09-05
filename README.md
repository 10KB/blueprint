# Blueprint
by [10KB](https://10kb.nl)

Blueprint keeps track of the attributes of your models. It:
* Generates migrations for you if you update your model's blueprint (only ActiveRecord at the moment)
* Provides you with helpers to use in your serializers or permitted attributes definition
* Can be extended with plugins
* Has support for inheritance and composition

## Installation

Add this line to your application's Gemfile:

    gem 'blueprint'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install blueprint

## Usage

1. Add Blueprint to your model

```ruby
class Car
  include Blueprint::Model
end
```

Alternatively, in an ActiveRecord model you could also use `has_blueprint`.

```ruby
class Car < ActiveRecord::Base
  has_blueprint
end
```

2. Add some attributes to your blueprint definition

```ruby
class Car < ActiveRecord::Base
  include Blueprint::Model

  blueprint do
    string  :brand, default: 'BMW'
    string  :name
    text    :description
    decimal :price, precision: 5, scale: 10
  end
end
```

3. Let Blueprint generate a migration to update your database for you. Run:

```
rake blueprint:migrate
```

Blueprint will check all your models for changes and list them in your terminal. If multiple models have changes it will ask you if you want to apply these changes in one or separate migrations.

```
Blueprint has detected 1 changes to your models.
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
1
How would you like to name this migration?
Create cars
== 20160905153022 CreateCars: migrating =======================================
-- create_table(:cars)
   -> 0.0081s
== 20160905153022 CreateCars: migrated (0.0082s) ==============================
```
