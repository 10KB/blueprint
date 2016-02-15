module Blueprint
  def self.config(&block)
    Config.instance_exec(Config, &block)
  end

  module Config
    class << self
      attr_accessor :default_adapter, :persisted_attribute_options
    end
  end
end
