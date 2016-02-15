module Blueprint
  module Adapters
    class ActiveRecord::Migration < Parslet::Transform
      rule(table_exists: false,
           table_name: simple(:table_name),
           attributes: subtree(:attributes)
      )                             { "  create_table :#{table_name} do |t|\n#{attributes.join("\n")}end\n"}

      rule(table_exists: true,
           table_name: simple(:table_name),
           attributes: subtree(:attributes)
      )                             { "  change_table :#{table_name} do |t|\n#{attributes.join("\n")}end\n"}

      rule(kind: :added,
           name: simple(:name),
           type: simple(:type),
           options: subtree(:options)
      )                             { "    t.#{type} :#{name}, #{options}" }

      rule(kind: :changed,
           name: simple(:name),
           type: simple(:type),
           options: subtree(:options)
      )                             { "    t.change :#{type}, :#{name}, #{options}" }

      rule(kind: :removed,
           name: simple(:name),
           type: simple(:type),
           options: subtree(:options)
      )                             { "    t.remove :#{name}" }
    end
  end
end
