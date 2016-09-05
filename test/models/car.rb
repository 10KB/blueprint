class Car < ActiveRecord::Base
  has_whiteprint

  whiteprint do
    string  :brand,          default: 'BMW'
    decimal :price,          precision: 5, scale: 10
  end
end
