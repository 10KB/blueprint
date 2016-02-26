module Blueprint
  module Adapters
    class ActiveRecord < ::Blueprint::Base
      require 'blueprint/adapters/active_record/migration'

      class << self
        def applicable?(model)
          return false unless defined?(::ActiveRecord)
          model < ::ActiveRecord::Base
        end

        def underscore(name)
          name = name.tr(' ', '_')
          name.gsub(/([a-z])([A-Z])/) { "#{Regexp.last_match[1]}_#{Regexp.last_match[2].downcase}" }.downcase
        end

        def camelize(name)
          name = underscore(name)
          name = name.gsub(/^([a-z])/) { Regexp.last_match[1].upcase }
          name.gsub(/_([a-zA-Z])/) { Regexp.last_match[1].upcase }
        end

        def generate_migration(name, trees)
          filename = "#{Time.now.strftime('%Y%m%d%H%M%S')}_#{underscore(name)}.rb"
          File.open(File.join(Blueprint.config.migration_path, filename), 'w') do |f|
            f.write migration(name, trees)
          end
        end

        def migration(name, trees)
          "class #{camelize(name)} < ActiveRecord::Migration\n  def change\n" + transform(trees) + "  end\nend\n"
        end

        private

        def transform(trees)
          Migration.new.apply(trees).join("\n")
        end
      end

      def initialize(model, id: true, timestamps: true, **_options)
        super(model)

        @has_id         = id
        @has_timestamps = timestamps
        @attributes.add(name: :id, type: :integer, null: false) if id
        @attributes.add(name: :created_at, type: :datetime)     if timestamps
        @attributes.add(name: :updated_at, type: :datetime)     if timestamps
      end

      def changes_tree
        changes_tree = super

        unless changes_tree[:table_exists]
          changes_tree[:has_id] = @has_id
          changes_tree[:attributes].reject! { |attribute| attribute[:name] == :id }
        end

        added_created_at = changes_tree[:attributes].select { |attribute| attribute[:name] == :created_at && attribute[:kind] == :added }
        added_updated_at = changes_tree[:attributes].select { |attribute| attribute[:name] == :updated_at && attribute[:kind] == :added }

        if added_created_at.size == 1 && added_updated_at.size == 1
          changes_tree[:attributes] -= [*added_created_at, *added_updated_at]
          changes_tree[:attributes] += [{ type: :timestamps, kind: :added }]
        end

        changes_tree
      end

      def persisted_attributes
        attributes = Blueprint::Attributes.new
        return attributes unless table_exists?
        model.columns.map do |column|
          attributes.add options_from_column(column)
        end
        attributes.for_persisted
      end

      def migration(name)
        self.class.migration(name, [changes_tree])
      end

      def options_from_column(column)
        [:name, :type, *Blueprint.config.persisted_attribute_options.keys].map do |option|
          next unless column.respond_to?(option)
          value = column.send(option)
          value = column.type_cast_from_database(value) if option == :default
          next if value == Blueprint.config.persisted_attribute_options[option]
          { option => value }
        end.compact.inject(&:merge)
      end

      def table_exists?
        ::ActiveRecord::Base.connection.schema_cache.clear!
        ::ActiveRecord::Base.connection.table_exists?(table_name)
      end
    end
  end
end
