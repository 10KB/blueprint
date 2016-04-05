module Blueprint
  module Adapters
    class ActiveRecord < ::Blueprint::Base
      require 'blueprint/adapters/active_record/migration'
      require 'blueprint/adapters/active_record/has_and_belongs_to_many'

      BELONGS_TO_OPTIONS = [:class_name, :anonymous_class, :foreign_key, :validate, :autosave,
                            :dependent, :primary_key, :inverse_of, :required, :foreign_type,
                            :polymorphic, :touch, :counter_cache]

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

        changes_tree[:attributes].each do |attribute|
          persisted_attribute = persisted_attributes[attribute[:name]]
          if persisted_attribute && attribute[:options][:default].nil? && persisted_attribute[:options][:default]
            changes_tree[:attributes] += [{ name: attribute[:name], kind: :removed_default }]
          end
        end

        changes_tree
      end

      def has_and_belongs_to_many(name, **options)
        model.send(:has_and_belongs_to_many, name.to_sym, **options) unless model.reflect_on_association(name)

        association = model.reflect_on_association(name)

        Class.new do
          include Blueprint::Model

          @association = association
          @join_table  = association.join_table

          blueprint(adapter: :has_and_belongs_to_many, id: false, timestamps: false) do
            integer association.foreign_key
            integer association.association_foreign_key
          end

          class << self
            def name
              "#{@join_table}_habtm_model"
            end

            def table_name
              @join_table
            end

            def table_exists?
              ::ActiveRecord::Base.connection.table_exists?(table_name)
            end
          end
        end
      end
      alias_method :habtm, :has_and_belongs_to_many

      def migration(name)
        self.class.migration(name, [changes_tree])
      end

      def options_from_column(column)
        [:name, :type, *Blueprint.config.persisted_attribute_options.keys].map do |option|
          association_by_foreign_key = find_association_by_foreign_key(column)
          overridden_name            = association_by_foreign_key && association_by_foreign_key.name || column.name
          current_attribute          = attributes[overridden_name]

          next {name: overridden_name}               if option == :name        && association_by_foreign_key
          next {type: :references}                   if option == :type        && association_by_foreign_key
          next {polymorphic: true}                   if option == :polymorphic && association_by_foreign_key && model.column_names.include?(association_by_foreign_key.foreign_type)
          next                                       unless column.respond_to?(option)
          next {default: current_attribute.default}  if option == :default && current_attribute && current_attribute.default.is_a?(Symbol)

          value = column.send(option)
          value = column.type_cast_from_database(value) if option == :default
          next if value == Blueprint.config.persisted_attribute_options[option]
          { option => value }
        end.compact.inject(&:merge)
      end

      def persisted_attributes
        attributes = Blueprint::Attributes.new
        return attributes unless table_exists?
        model.columns.each do |column|
          next if find_association_by_foreign_type(column)

          attributes.add options_from_column(column)
        end
        attributes.for_persisted
      end

      def references(name, **options)
        super
        model.send :belongs_to, name.to_sym, **options.slice(*BELONGS_TO_OPTIONS)
      end

      def table_exists?
        ::ActiveRecord::Base.connection.schema_cache.clear!
        ::ActiveRecord::Base.connection.table_exists?(table_name)
      end

      def method_missing(type, name, **options)
        super

        if options[:default] && options[:default].is_a?(Symbol)
          model.send :after_initialize do
            next if self.send(name) || !new_record?
            self.send "#{name}=", send(options[:default])
          end
        end
      end

      private

      def find_association_by_foreign_key(column)
        model.reflect_on_all_associations.find do |association|
          association.foreign_key == column.name
        end
      end

      def find_association_by_foreign_type(column)
        model.reflect_on_all_associations.find do |association|
          association.polymorphic? && association.foreign_type == column.name
        end
      end
    end
  end
end
