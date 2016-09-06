module Whiteprint
  class Railtie < Rails::Railtie
    initializer "whiteprint.config_for_rails" do
      ::Whiteprint.config do |c|
        c.eager_load        = true
        c.migration_path    = Rails.root.join(ActiveRecord::Migrator.migrations_path)
      end
    end

    rake_tasks do
      load "tasks/whiteprint.rake"
    end
  end
end
