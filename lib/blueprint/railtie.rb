module Blueprint
  class Railtie < Rails::Railtie
    initializer "blueprint.config_for_rails" do
      ::Blueprint.config do |c|
        c.eager_load        = true
        c.migration_path    = Rails.root.join(ActiveRecord::Migrator.migrations_path)
      end
    end

    rake_tasks do
      ::Blueprint.config do |c|
        c.eager_load        = true
        c.migration_path    = Rails.root.join(ActiveRecord::Migrator.migrations_path)
      end
      load "tasks/blueprint.rake"
    end
  end
end
