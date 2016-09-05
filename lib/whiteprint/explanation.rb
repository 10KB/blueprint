module Whiteprint
  module Explanation
    class << self
      def apply(whiteprint, index, width: 100)
        @table     = { title: "#{index}. ", rows: [], style: { width: width } }
        @whiteprint = whiteprint
        transformer.new.apply(whiteprint.changes_tree)
        @table
      end

      private

      def helpers
        type_was = lambda do |name|
          @whiteprint.persisted_attributes[name][:type].to_s
        end

        options_was = lambda do |name|
          @whiteprint.persisted_attributes[name][:options].to_s
        end

        table_exists = @whiteprint.changes_tree[:table_exists]

        [type_was, options_was, table_exists]
      end

      def transformer
        table, type_was, options_was, table_exists = @table, *helpers

        Class.new(Whiteprint::Transform) do
          create_table do
            table[:headings]  = %w(name type options)
            table[:title]    += "Create a new table #{table_name}"
          end

          create_table_without_id do
            table[:headings]  = %w(name type options)
            table[:title]    += "Create a new table #{table_name} (without id)"
          end

          change_table do
            table[:headings]  = ['action', 'name', 'type', 'type (currently)', 'options', 'options (currently)']
            table[:title]    += "Make changes to #{table_name}"
          end

          added_attribute do
            table[:rows] << if table_exists
                              ['added', name, type, nil, options.to_s, nil]
                            else
                              [name, type, options.to_s]
                            end
          end

          added_timestamps do
            table[:rows] << if table_exists
                              ['added', 'timestamps', nil, nil, nil, nil]
                            else
                              ['timestamps', nil, nil]
                            end
          end

          changed_attribute do
            table[:rows] << ['change', name, type, type_was[name],  options.to_s, options_was[name]]
          end

          removed_attribute do
            table[:rows] << ['remove', name, nil, nil, nil, nil]
          end
        end
      end
    end
  end
end
