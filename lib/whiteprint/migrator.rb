module Whiteprint
  module Migrator
    class << self
      def eager_load!
        return unless Whiteprint.config.eager_load

        Rails.application.eager_load! if defined?(Rails)

        [*Whiteprint.config.eager_load_paths.uniq].each do |path|
          Gem.find_files(path).each do |file|
            load file
          end
        end
      end

      def explanations
        Whiteprint.changed_whiteprints.map.with_index do |whiteprint, index|
          whiteprint.explanation(index + 1)
        end
      end

      def interactive(input: $stdin, output: $stdout, migrate_input: $stdin, migrate_output: $stdout)
        # TODO: Clean up

        eager_load!
        cli = HighLine.new input, output

        if number_of_changes == 0
          cli.say('Whiteprint detected no changes')
          return
        end

        cli.say "Whiteprint has detected <%= color('#{number_of_changes}', :bold, :white) %> changes to your models."
        explanations.each do |explanation|
          cli.say explanation
        end

        cli.choose do |menu|
          menu.header = 'Migrations'
          menu.prompt = 'How would you like to process these changes?'
          menu.choice('In one migration')       { migrate_at_once(input: migrate_input, output: migrate_output) }
          menu.choice('In separate migrations') { cli.say 'Bar' }
        end
      end

      def migrate_at_once(input: $stdin, output: $stdout)
        # TODO: Clean up

        cli = HighLine.new input, output
        name = cli.ask 'How would you like to name this migration?'
        Whiteprint.changed_whiteprints
                 .group_by(&:transformer)
                 .map do |adapter, whiteprints|
                   adapter.generate_migration(name, whiteprints.map(&:changes_tree))
                 end

        ActiveRecord::Migration.verbose = true
        ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths)
      end

      def number_of_changes
        Whiteprint.changed_whiteprints.size
      end
    end
  end
end
