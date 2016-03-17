module Blueprint
  module Adapters
    class ActiveRecord::Migration < Blueprint::Transform
      create_rule :removed_default, kind: :removed_default, name: simple(:name)

      create_table            { "    create_table :#{table_name} do |t|\n#{attributes.join("\n")}\n    end\n" }
      create_table_without_id { "    create_table :#{table_name}, id: false do |t|\n#{attributes.join("\n")}\n    end\n" }
      change_table            { "    change_table :#{table_name} do |t|\n#{attributes.join("\n")}\n    end\n" }

      added_attribute         { "      t.#{type} :#{name}, #{options}" }
      changed_attribute       { "      t.change :#{name}, :#{type}, #{options}" }
      removed_attribute       { "      t.remove :#{name}" }
      removed_default         { "      t.change_default :#{name}, nil" }
      added_timestamps        { '      t.timestamps' }
    end
  end
end
