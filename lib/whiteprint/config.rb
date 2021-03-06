module Whiteprint
  def self.config(&block)
    return Config unless block
    Config.instance_exec(Config, &block)
  end

  module Config
    class << self
      attr_accessor :default_adapter, :persisted_attribute_options, :eager_load, :eager_load_paths,
                    :migration_path, :meta_attribute_options, :plugins, :migration_strategy, :add_migration_to_git

      def plugin(name)
        self.plugins << name
      end
    end

    self.plugins = []
  end
end
