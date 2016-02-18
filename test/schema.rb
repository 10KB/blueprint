ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, :force => true do |t|
    t.string  :name,          default: 'John'
    t.integer :age,           default: 0
    t.date    :date_of_birth

    t.timestamps null: true
  end
end
