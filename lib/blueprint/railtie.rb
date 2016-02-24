module Blueprint
  class Railtie < Rails::Railtie
    class << self
      def blueprint_config
        ::Blueprint.config do |c|
          c.eager_load        = true
          c.migration_path    = Rails.root.join(ActiveRecord::Migrator.migrations_path)
        end
      end
    end

    initializer "blueprint.config_for_rails" do
      ::Blueprint.config do |c|
        c.eager_load        = true
        c.migration_path    = Rails.root.join(ActiveRecord::Migrator.migrations_path)
      end
    end

    rake_tasks do
      # blueprint_config
      load "tasks/blueprint.rake"
    end
  end
end
