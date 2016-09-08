module Whiteprint
  module Adapters
    class ActiveRecord < ::Whiteprint::Base
      require 'whiteprint/adapters/active_record/migration'

      plugin :accessor
      plugin :has_and_belongs_to_many
      plugin :inflector
      plugin :references

      class << self
        def applicable?(model)
          return false unless defined?(::ActiveRecord)
          model < ::ActiveRecord::Base
        end

        def generate_migration(name, trees)
          filename = "#{Time.now.strftime('%Y%m%d%H%M%S')}_#{underscore(name)}.rb"
          path     = File.join(Whiteprint.config.migration_path, filename)
          File.open(path, 'w') do |f|
            f.write migration(name, trees)
          end
          path
        end

        def migrate
          ::ActiveRecord::Migration.verbose = true
          ::ActiveRecord::Migrator.migrate(::ActiveRecord::Migrator.migrations_paths)
        end

        def migration(name, trees)
          "class #{camelize(name)} < ActiveRecord::Migration\n  def change\n" + transform(trees) + "  end\nend\n"
        end

        def migration_params(cli)
          name = cli.ask 'How would you like to name this migration?'
          [name]
        end

        private

        def transform(trees)
          Migration.new.apply(trees).join("\n")
        end
      end

      def initialize(model, id: true, timestamps: true, auto_belongs_to: true, **_options)
        super(model, id: true, timestamps: true, **_options)
        @has_id, @has_timestamps, @auto_belongs_to = id, timestamps, auto_belongs_to
        set_default_attributes
      end

      def connection
        model.try(:connection) || ::ActiveRecord::Base.connection
      end

      def changes_tree
        changes_tree = super

        transform_id_to_option!         changes_tree
        transform_timestamps_to_option! changes_tree
        transform_removed_default!      changes_tree

        changes_tree
      end

      def migration(name)
        self.class.migration(name, [changes_tree])
      end

      def options_from_column(column)
        persisted_attribute_options.map do |option|
          association, overridden_name, current_attribute = inspect_column(column)
          option_from_association = association && option_from_association(association, name: overridden_name, option: option)

          next option_from_association if option_from_association
          next unless column.respond_to?(option)
          next {default: current_attribute.default}  if option == :default && current_attribute && current_attribute.default.is_a?(Symbol)

          value = option_value_from_column(column, option)
          next if value == Whiteprint.config.persisted_attribute_options[option]

          { option => value }
        end.compact.inject(&:merge)
      end

      def persisted_attributes
        attributes = Whiteprint::Attributes.new
        return attributes unless table_exists?

        model.columns.each do |column|
          next if find_association_by_foreign_type(column)
          attributes.add options_from_column(column)
        end

        attributes.for_persisted
      end

      def persisted_attribute_options
        [:name, :type, *Whiteprint.config.persisted_attribute_options.keys]
      end

      def table_exists?
        connection.schema_cache.clear!
        connection.table_exists?(table_name)
      end

      def method_missing(type, name, **options)
        super
        set_dynamic_default(name, options)
      end

      private

      def inspect_column(column)
        association       = find_association_by_foreign_key(column)
        overridden_name   = association && association.name || column.name
        current_attribute = attributes[overridden_name]

        [association, overridden_name, current_attribute]
      end

      def find_association_by_foreign_key(column)
        model.reflect_on_all_associations.find do |association|
          association.foreign_key == column.name
        end
      end

      def find_association_by_foreign_type(column)
        model.reflect_on_all_associations.find do |association|
          association.polymorphic? && association.foreign_type.to_s == column.name.to_s
        end
      end

      def option_from_association(association, name:, option:)
        if    option == :name
          {name: name}
        elsif option == :type
          {type: :references}
        elsif option == :polymorphic && model.column_names.include?(association.foreign_type)
          {polymorphic: true}
        end
      end

      def option_value_from_column(column, option)
        value = column.send(option)
        option == :default ? column.type_cast_from_database(value) : value
      end

      def set_default_attributes
        @attributes.add(name: :id, type: :integer, null: false) if @has_id
        @attributes.add(name: :created_at, type: :datetime)     if @has_timestamps
        @attributes.add(name: :updated_at, type: :datetime)     if @has_timestamps
      end

      def set_dynamic_default(name, options)
        return unless options[:default] && options[:default].is_a?(Symbol)
        model.send :after_initialize do
          next if self.send(name) || !new_record?
          self.send "#{name}=", send(options[:default])
        end
      end

      def transform_id_to_option!(changes_tree)
        return if changes_tree[:table_exists]
        changes_tree[:has_id] = @has_id
        changes_tree[:attributes].reject! do |attribute|
          attribute[:name] == :id
        end
      end

      def transform_removed_default!(changes_tree)
        changes_tree[:attributes].each do |attribute|
          persisted_attribute = persisted_attributes[attribute[:name]]
          if persisted_attribute && attribute[:options][:default].nil? && persisted_attribute[:options][:default]
            changes_tree[:attributes] += [{ name: attribute[:name], kind: :removed_default }]
          end
        end
      end

      def transform_timestamps_to_option!(changes_tree)
        added_created_at = changes_tree[:attributes].find do |attribute|
          attribute[:name] == :created_at && attribute[:kind] == :added
        end

        added_updated_at = changes_tree[:attributes].find do |attribute|
          attribute[:name] == :updated_at && attribute[:kind] == :added
        end

        return unless added_created_at && added_updated_at

        changes_tree[:attributes] -= [added_created_at, added_updated_at]
        changes_tree[:attributes] += [{ type: :timestamps, kind: :added }]
      end
    end
  end
end
