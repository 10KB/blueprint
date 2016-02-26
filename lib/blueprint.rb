require 'blueprint/version'

module Blueprint
  require 'active_support/concern' unless defined?(ActiveSupport)
  require 'active_support/inflections'

  require 'parslet'
  require 'terminal-table'
  require 'highline'

  require 'blueprint/attributes'
  require 'blueprint/base'
  require 'blueprint/config'
  require 'blueprint/explanation'
  require 'blueprint/model'
  require 'blueprint/migrator'
  require 'blueprint/transform'

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
  end

  if defined?(ActiveRecord)
    require 'blueprint/has_blueprint'
    ActiveSupport.on_load :active_record do
      ActiveRecord::Base.send :extend, Blueprint::HasBlueprint
    end
  end

  require 'blueprint/railtie' if defined?(Rails)

  require 'blueprint/adapters/active_record'
  require 'blueprint/adapters/test'

  ADAPTERS = {
    active_record:  Adapters::ActiveRecord,
    test:           Adapters::Test,
    base:           Base
  }.freeze

  class << self
    def new(model, adapter: nil, **options)
      if adapter
        ADAPTERS[adapter].new(model, **options)
      else
        adapter = ADAPTERS.find do |_, blueprint|
          blueprint.applicable?(model)
        end

        adapter[-1].new(model, **options)
      end
    end

    @@models = []
    def models=(models)
      @@models = models
    end

    def models
      @@models.sort_by { |model| model.name || 'anonymous' }
    end

    def blueprints
      models.map(&:blueprint)
    end

    def changed_blueprints
      blueprints.select(&:changes?)
    end
  end
end
