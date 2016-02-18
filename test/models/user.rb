class User < ActiveRecord::Base
  include Blueprint::Model

  blueprint do
    string  :name,          default: 'Joe'
    integer :age,           default: 10
  end
end
