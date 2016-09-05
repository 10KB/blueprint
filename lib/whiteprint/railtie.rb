module Whiteprint
  class Railtie < Rails::Railtie
    class << self
      def whiteprint_config
        ::Whiteprint.config do |c|
          c.eager_load        = true
          c.migration_path    = Rails.root.join(ActiveRecord::Migrator.migrations_path)
        end
      end
    end

    initializer "whiteprint.config_for_rails" do
      ::Whiteprint.config do |c|
        c.eager_load        = true
        c.migration_path    = Rails.root.join(ActiveRecord::Migrator.migrations_path)
      end
    end

    rake_tasks do
      # whiteprint_config
      load "tasks/whiteprint.rake"
    end
  end
end
