require "blueprint/version"

module Blueprint
  require 'active_support/concern' unless defined?(ActiveSupport)

  require 'blueprint/attributes'
  require 'blueprint/base'
  require 'blueprint/config'
  require 'blueprint/model'

  require 'parslet'

  config do |c|
    c.default_adapter = :base
    c.persisted_attribute_options = [:limit, :precision, :scale, :polymorphic, :null, :default]
  end

  if defined?(ActiveRecord)
    require 'blueprint/has_blueprint'
    ActiveSupport.on_load :active_record do
      ActiveRecord::Base.send :extend, Blueprint::HasBlueprint
    end
  end

  require 'blueprint/adapters/active_record'
  require 'blueprint/adapters/test'

  ADAPTERS = {
      active_record:  Adapters::ActiveRecord,
      test:           Adapters::Test,
      base:           Base
  }

  class << self
    def config
      Config
    end

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
  end
end
