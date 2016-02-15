module Blueprint
  def self.config(&block)
    Config.instance_exec(Config, &block)
  end

  module Config
    class << self
      attr_accessor :default_adapter
    end
    self.default_adapter = :active_record
  end
end