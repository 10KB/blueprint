module Blueprint
  class Attribute
    def initialize(persisted: nil, model: nil, **options)
      @model     = model
      @options   = options
      @persisted = persisted
    end

    def ==(other)
      to_h == other.to_h
    end

    def has?(*keys, **conditions)
      keys.none? do |key|
        @options.values_at(*key).compact.empty?
      end && conditions.all? do |key, value|
        [*@options[key]] & [*value] != []
      end
    end

    def persisted_options
      @options.select do |key, value|
        Blueprint.config.persisted_attribute_options.keys.include?(key) &&
        !(key == :default && value.is_a?(Symbol))
      end
    end

    def to_h
      @options
    end

    def merge(options)
      self.class.new(persisted: @persisted, **@options, **options)
    end

    def for_meta(instance)
      ::Blueprint.config.meta_attribute_options.map do |option|
        {option => send("meta_#{option}", instance)}
      end.inject(&:merge).compact
    end

    def for_persisted(**config)
      return merge(config) if @persisted
      self.class.new(persisted: true, name: @options[:name], type: @options[:type], options: persisted_options, **config)
    end

    def [](name)
      @options[name.to_sym]
    end

    def meta_enum(instance)
      _enum = if enum.is_a?(Symbol)
                instance.send(enum)
              else
                enum
              end

      return _enum if _enum.is_a?(Hash)

      _enum.map do |value|
        {value => value}
      end.inject(&:merge)
    end

    def method_missing(name)
      if name.to_s.starts_with?('meta_')
        self[name.to_s.remove(/^meta_/)]
      else
        self[name]
      end
    end
  end

  class AttributeScope
    def initialize(scope, model: nil)
      @scope   = scope
      @model   = model
      @selects = []
      @rejects = []
    end

    def where(*keys, **conditions)
      @selects << proc do |_, attribute|
        attribute.has?(*keys, **conditions)
      end
      Attributes.new(filter, model: @model)
    end

    def not(*keys, **conditions)
      @rejects << proc do |_, attribute|
        attribute.has?(*keys, **conditions)
      end
      Attributes.new(filter, model: @model)
    end

    def filter
      select = proc { |scope, condition| scope.select(&condition) }
      reject = proc { |scope, condition| scope.reject(&condition) }

      scope = @selects.inject(@scope, &select)
      @rejects.inject(scope, &reject)
    end
  end

  class Attributes
    def initialize(attributes = nil, model: nil)
      attributes  = Hash[attributes] if attributes.is_a?(Array)
      @attributes = (attributes || {}).dup
      @model      = model
    end

    def add(name:, type:, **options)
      @attributes[name.to_sym] = Attribute.new(name: name.to_sym, type: type.to_sym, model: @model, **options)
    end

    def as_json(*args)
      super['attributes']
    end

    def diff(diff, type: nil)
      # TODO: Clean up
      added   = diff.slice(*(diff.keys - keys))
      changed = diff.to_diff_a(type) - to_diff_a(type) - added.to_diff_a(type)
      changed = Attributes.new(Hash[changed].map { |key, options| { key => Attribute.new(persisted: true, model: @model, **options) } }.inject(&:merge), model: @model)
      removed = slice(*(keys - diff.keys))

      { added: added, changed: changed, removed: removed }
    end

    def where(*keys, **conditions)
      AttributeScope.new(@attributes, model: @model).where(*keys, **conditions)
    end

    def not(*keys, **conditions)
      AttributeScope.new(@attributes, model: @model).not(*keys, **conditions)
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

    def to_a
      @attributes.values
    end

    def for_persisted
      persisted_scope = self.not(virtual: true)
      persisted_scope.to_h.each do |name, attribute|
        persisted_scope.to_h[name] = attribute.for_persisted
      end
      persisted_scope
    end

    def for_meta(instance)
      where(::Blueprint.config.meta_attribute_options).to_h.map do |key, attribute|
        {key => attribute.for_meta(instance)}
      end.inject(&:merge)
    end

    def for_serializer
      self.not(type: :references).not(private: true).keys
    end

    def for_permitted
      self.not(readonly: true).to_h.map do |name, attribute|
        if attribute.array
          {name => []}
        elsif attribute.type == :has_and_belongs_to_many
          {"#{name.to_s.singularize}_ids" => []}
        elsif attribute.type == :references
          "#{attribute.name}_id"
        else
          name
        end
      end
    end

    def for_permitted_json
      self.not(readonly: true).where(type: [:json, :jsonb]).keys
    end

    def to_diff_a(type)
      if type
        to_h.map { |name, attr| [name, attr.send("for_#{type}").to_h] }
      else
        to_h.map { |name, attr| [name, attr.to_h] }
      end
    end

    def [](name)
      return unless name
      @attributes[name.to_sym]
    end

    def method_missing(name)
      self[name]
    end
  end
end
