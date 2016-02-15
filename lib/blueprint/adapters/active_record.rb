module Blueprint
  module Adapters
    class ActiveRecord < ::Blueprint::Base
      require 'blueprint/adapters/active_record/migration'

      class << self
        def applicable?(model)
          return false unless defined?(::ActiveRecord)
          model < ::ActiveRecord::Base
        end

        def generate_migration
          File.open()
        end

        def migration(name, trees)
          "class #{name} < ActiveRecord::Migration\n" + transform(trees) + "  end"
        end

        private

        def transform(trees)
          Migration.new.apply(trees).join("\n")
        end
      end

      def persisted_attributes
        ::Blueprint::Attributes.new
      end

      def table_exists?
        return false
        ActiveRecord::Base.connection.schema_cache.clear!
        ActiveRecord::Base.connection.table_exists?(table_name)
      end
    end
  end
end
