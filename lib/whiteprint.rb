require 'whiteprint/version'

module Whiteprint
  require 'active_support/concern' unless defined?(ActiveSupport)
  require 'active_support/inflections'

  require 'parslet'
  require 'terminal-table'
  require 'highline'

  require 'whiteprint/config'
  require 'whiteprint/attributes'
  require 'whiteprint/base'
  require 'whiteprint/explanation'
  require 'whiteprint/model'
  require 'whiteprint/migrator'
  require 'whiteprint/transform'

  config do |c|
    c.default_adapter             = :base
    c.eager_load                  = false
    c.eager_load_paths            = []
    c.persisted_attribute_options = {
      array: false,
      limit: nil,
      precision: nil,
      scale: nil,
      polymorphic: false,
      null: true,
      default: nil
    }
    c.meta_attribute_options      = [:enum]
    c.migration_strategy          = :ask
    c.add_migration_to_git        = false
  end

  if defined?(ActiveRecord)
    require 'whiteprint/has_whiteprint'
    ActiveSupport.on_load :active_record do
      ActiveRecord::Base.send :extend, Whiteprint::HasWhiteprint
    end
  end

  require 'whiteprint/railtie' if defined?(Rails)

  require 'whiteprint/adapters/active_record'
  require 'whiteprint/adapters/active_record/has_and_belongs_to_many'
  require 'whiteprint/adapters/test'

  ADAPTERS = {
    active_record:            Adapters::ActiveRecord,
    has_and_belongs_to_many:  Adapters::ActiveRecord::HasAndBelongsToMany,
    test:                     Adapters::Test,
    base:                     Base
  }.freeze

  class << self
    def new(model, adapter: nil, **options)
      if adapter
        ADAPTERS[adapter].new(model, **options)
      else
        adapter = ADAPTERS.find do |_, whiteprint|
          whiteprint.applicable?(model)
        end

        adapter[-1].new(model, **options)
      end
    end

    @@models  = []
    @@plugins = {}

    def models=(models)
      @@models = models
    end

    def models
      @@models.select  { |model| model.is_a?(Class) }
              .reject  { |model| model.respond_to?(:abstract_class) && model.abstract_class }
              .sort_by { |model| model.respond_to?(:table_name) && model.table_name || model.name || model.object_id.to_s }
              .sort    { |a, b|  -1 * (a <=> b).to_i }
              .uniq    { |model| model.respond_to?(:table_name) && model.table_name || model.name || model.object_id.to_s }
              .sort_by { |model| model.name || model.object_id.to_s }
    end

    def whiteprints
      models.map(&:whiteprint).compact
    end

    def changed_whiteprints
      whiteprints.select(&:changes?)
    end

    def migrate(cli, separately:)
      changed_whiteprints.group_by(&:transformer).map do |adapter, whiteprints|
        if separately
          cli.say 'Processing as separate migrations...'
          whiteprints.each do |whiteprint|
            cli.say whiteprint.explanation
            migration_path = adapter.generate_migration(*adapter.migration_params(cli), [whiteprint.changes_tree])
            `git add #{migration_path}` if Whiteprint.config.add_migration_to_git
          end
        else
          cli.say 'Processing as a single migration...'
          migration_path = adapter.generate_migration(*adapter.migration_params(cli), whiteprints.map(&:changes_tree))
          `git add #{migration_path}` if Whiteprint.config.add_migration_to_git
        end

        adapter.migrate
      end
    end

    def plugins
      @@plugins
    end

    def register_plugin(name, constant)
      @@plugins[name] = constant
    end
    require 'whiteprint/plugins'
  end
end
