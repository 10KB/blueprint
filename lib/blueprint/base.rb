module Blueprint
  class Base
    attr_accessor :model, :attributes

    class << self
      def applicable?(_)
        true
      end
    end

    def initialize(model, **options)
      self.model      = model
      self.attributes = Attributes.new
    end

    def method_missing(type, name, **options)
      @attributes.add name: name, type: type, **options
    end
  end
end
