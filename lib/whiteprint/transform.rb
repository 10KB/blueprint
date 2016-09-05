module Whiteprint
  class Transform < Parslet::Transform
    class << self
      def create_rule(name, **expression)
        define_singleton_method name do |&block|
          rule(expression, &block)
        end
      end

      def table_expression
        {
          table_name: simple(:table_name),
          attributes: subtree(:attributes)
        }
      end

      def attribute_expression
        {
          name: simple(:name),
          type: simple(:type),
          options: subtree(:options)
        }
      end
    end

    create_rule :create_table,             table_exists: false, has_id: true,  **table_expression
    create_rule :create_table_without_id,  table_exists: false, has_id: false, **table_expression
    create_rule :change_table,             table_exists: true,                 **table_expression

    create_rule :added_attribute,          kind: :added,   **attribute_expression
    create_rule :changed_attribute,        kind: :changed, **attribute_expression
    create_rule :removed_attribute,        kind: :removed, **attribute_expression
    create_rule :added_timestamps,         kind: :added,   type: :timestamps
  end
end
