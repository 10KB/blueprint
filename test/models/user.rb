class User < ActiveRecord::Base
  include Whiteprint::Model

  whiteprint do
    string  :name,          default: 'Joe'
    integer :age,           default: 10
  end
end
