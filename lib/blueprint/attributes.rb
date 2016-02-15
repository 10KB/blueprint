module Blueprint
  class Attribute
    def initialize(**options)
      @options = options
    end

    def has?(*keys, **conditions)
      keys.none? do |key|
        @options[key].nil?
      end && conditions.all? do |key, value|
        [*@options[key]] & [*value] != []
      end
    end

    def to_h
      @options
    end

    def [](name)
      @options[name.to_sym]
    end

    def method_missing(name)
      self[name]
    end
  end

  class AttributeScope
    def initialize(scope)
      @scope   = scope
      @selects = []
      @rejects = []
    end

    def where(*keys, **conditions)
      @selects << proc do |_, attribute|
        attribute.has?(*keys, **conditions)
      end
      Attributes.new(filter)
    end

    def not(*keys, **conditions)
      @rejects << proc do |_, attribute|
        attribute.has?(*keys, **conditions)
      end
      Attributes.new(filter)
    end

    def filter
      select = proc { |scope, condition| scope.select(&condition) }
      reject = proc { |scope, condition| scope.reject(&condition) }

      scope = @selects.inject(@scope, &select)
      @rejects.inject(scope, &reject)
    end
  end

  class Attributes
    def initialize(attributes = {})
      attributes  = Hash[attributes] if attributes.is_a?(Array)
      @attributes = attributes
    end

    def add(name:, type:, **options)
      @attributes[name.to_sym] = Attribute.new(name: name.to_sym, type: type.to_sym, **options)
    end

    def diff(diff)
      added   = diff.slice(*(diff.keys - keys))
      changed = self.class.new(diff.to_h.to_a - to_h.to_a - added.to_h.to_a)
      removed = slice(*(keys - diff.keys))
    
      {added: added, changed: changed, removed: removed}
    end

    def where(*keys, **conditions)
      AttributeScope.new(@attributes).where(*keys, **conditions)
    end

    def not(*keys, **conditions)
      AttributeScope.new(@attributes).not(*keys, **conditions)
    end

    def keys
      @attributes.keys
    end

    def slice(*keys)
      where(name: keys)
    end

    def to_h
      @attributes
    end

    def [](name)
      @attributes[name.to_sym]
    end

    def method_missing(name)
      self[name]
    end
  end
end
