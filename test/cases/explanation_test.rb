require 'test_helper'

class ExplanationTest < ActiveSupport::TestCase
  test 'the changes blueprint is about to process can be visualized in a table' do
    user_explanation = <<-TXT.sub(/\n$/, '')
+--------+---------------+---------+------------------+-------------------+------------------------+
|                                     1. Make changes to users                                     |
+--------+---------------+---------+------------------+-------------------+------------------------+
| action | name          | type    | type (currently) | options           | options (currently)    |
+--------+---------------+---------+------------------+-------------------+------------------------+
| change | name          | string  | string           | {:default=>"Joe"} | {:default=>"John"}     |
| change | age           | integer | integer          | {:default=>10}    | {:default=>0}          |
| remove | date_of_birth |         |                  |                   |                        |
+--------+---------------+---------+------------------+-------------------+------------------------+
TXT

    car_explanation = <<-TXT.sub(/\n$/, '')
+---------------------------+------------------------+---------------------------------------------+
|                                    1. Create a new table cars                                    |
+---------------------------+------------------------+---------------------------------------------+
| name                      | type                   | options                                     |
+---------------------------+------------------------+---------------------------------------------+
| brand                     | string                 | {:default=>"BMW"}                           |
| price                     | decimal                | {:precision=>5, :scale=>10}                 |
| timestamps                |                        |                                             |
+---------------------------+------------------------+---------------------------------------------+
    TXT

    assert_equal user_explanation, User.blueprint.explanation.to_s
    assert_equal car_explanation,  Car.blueprint.explanation.to_s
  end
end
