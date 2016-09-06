module Whiteprint
  module Migrator
    class Cli
      def initialize(input, output)
        @cli = HighLine.new input, output
      end

      def ask(*args)
        @cli.ask(*args)
      end

      def choose(*args, &block)
        @cli.choose(*args, &block)
      end

      def say(*messages)
        messages.each do |message|
          @cli.say(message)
        end
      end
    end

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

      def no_changes?
        number_of_changes == 0
      end

      def interactive(input: $stdin, output: $stdout)
        eager_load!
        cli = Cli.new(input, output)

        # return if there are no changes
        cli.say('Whiteprint detected no changes') and return if no_changes?

        # list all changes
        cli.say "Whiteprint has detected <%= color('#{number_of_changes}', :bold, :white) %> changes to your models.", *explanations

        if Whiteprint.config.migration_strategy == :ask
          cli.choose do |menu|
            menu.header = 'Migrations'
            menu.prompt = 'How would you like to process these changes?'
            menu.choice('In one migration')       { Whiteprint.migrate cli, separately: false }
            menu.choice('In separate migrations') { Whiteprint.migrate cli, separately: true }
          end
        else
          Whiteprint.migrate cli, separately: (Whiteprint.config.migration_strategy == :separately)
        end
      end

      def number_of_changes
        Whiteprint.changed_whiteprints.size
      end
    end
  end
end
