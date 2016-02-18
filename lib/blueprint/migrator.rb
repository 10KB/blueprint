module Blueprint
  module Migrator
    class << self
      def eager_load!
        return unless Blueprint.config.eager_load

        Blueprint.models = []
        Rails.application.eager_load! if defined?(Rails)

        [*Blueprint.config.eager_load_paths].each do |path|
          Gem.find_files(path).each do |file|
            require file
          end
        end
      end

      def explanations
        Blueprint.changed_blueprints.map.with_index do |blueprint, index|
          blueprint.explanation(index + 1)
        end
      end

      def interactive
        eager_load!
        cli = HighLine.new

        cli.say "Blueprint detected no changes" and return if number_of_changes == 0
        cli.say "Blueprint has detected <%= color('#{number_of_changes}', :bold, :blue) %> changes to your models."
        explanations.each do |explanation|
          cli.say explanation
        end
        cli.choose do |menu|
          menu.header = "Migrations"
          menu.prompt = "How would you like to process these changes?"
          menu.choice('In one migration')       { migrate_at_once }
          menu.choice('In separate migrations') { cli.say 'Bar' }
        end
      end

      def migrate_at_once
        cli = HighLine.new
        name = cli.ask "How would you like to name this migration?"
        Blueprint.changed_blueprints.group_by do |blueprint|
          blueprint.class
        end.map do |adapter, blueprints|
          adapter.generate_migration(name, blueprints.map(&:changes_tree))
        end

        ActiveRecord::Migration.verbose = true
        ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths)
      end

      def number_of_changes
        Blueprint.changed_blueprints.size
      end
    end
  end
end
