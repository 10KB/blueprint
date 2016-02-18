module Blueprint
  class Explanation
    def self.apply(blueprint, index)
      @table = {title: "#{index}. ", rows: [], style: {width: 100}}

      changes_tree, persisted_attributes, table = blueprint.changes_tree, blueprint.persisted_attributes, @table
      transformer = Class.new(Parslet::Transform) do
        rule(table_exists: false,
             has_id: true,
             table_name: simple(:table_name),
             attributes: subtree(:attributes)
        ) {
          table[:headings]  = ['name', 'type', 'options']
          table[:title]     += "Create a new table #{table_name}"
        }

        rule(table_exists: false,
             has_id: false,
             table_name: simple(:table_name),
             attributes: subtree(:attributes)
        ) {
          table[:headings]  = ['name', 'type', 'options']
          table[:title]     += "Create a new table #{table_name} (without id)"
        }

        rule(table_exists: true,
             table_name: simple(:table_name),
             attributes: subtree(:attributes)
        ) {
          table[:headings]  = ['action', 'name', 'type', 'type (currently)', 'options', 'options (currently)']
          table[:title]     += "Make changes to #{table_name}"
        }

        rule(kind: :added,
             name: simple(:name),
             type: simple(:type),
             options: subtree(:options)
        ) {
          if !changes_tree[:table_exists]
            table[:rows] << [name, type, options.to_s]
          else
            table[:rows] << ['added', name, type, nil, options.to_s, nil]
          end
        }

        rule(kind: :added,
             type: :timestamps,
        ) {
          if !changes_tree[:table_exists]
            table[:rows] << ['timestamps', nil, nil]
          else
            table[:rows] << ['added', 'timestamps', nil, nil, nil, nil]
          end
        }

        rule(kind: :changed,
             name: simple(:name),
             type: simple(:type),
             options: subtree(:options)
        )                             {
          table[:rows] << ['change', name, type, persisted_attributes[name][:type],  options.to_s, persisted_attributes[name][:options].to_s]
        }

        rule(kind: :removed,
             name: simple(:name),
             type: simple(:type),
             options: subtree(:options)
        )                             { table[:rows] << ['remove', name, nil, nil, nil, nil] }
      end

      transformer.new.apply(changes_tree)
      table
    end
  end
end
