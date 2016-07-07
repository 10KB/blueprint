module Blueprint
  class Base
    attr_accessor :model, :attributes, :configs, :options

    class << self
      def applicable?(_)
        true
      end

      def load_plugins
        Blueprint.config.plugins.each do |plugin|
          include Blueprint.plugins[plugin]
        end
      end
    end

    def initialize(model, **_options)
      singleton_class.send :load_plugins

      self.model                 = model
      self.options               = _options
      self.attributes            = Attributes.new(nil, model: model)
      self.configs               = []
    end

    def execute(&block)
      self.configs << block
      instance_eval(&block)
    end

    def explanation(index = 1, width = 100)
      return unless changes?
      table = Terminal::Table.new(Explanation.apply(self, index, width: width))
      table.render
      table
    rescue => e
      explanation(index, width + 10)
    end

    def changes_tree
      changes = persisted_attributes.diff(attributes.not(virtual: true), type: :persisted)

      attributes = changes.flat_map do |kind, changed_attributes|
        changed_attributes.to_a.map do |attribute|
          next if attribute.virtual
          attribute.for_persisted(kind: kind).to_h
        end.compact
      end

      table_name_without_schema = table_name.split('.').last

      { table_name: table_name_without_schema, table_exists: table_exists?, attributes: attributes }
    end

    def changes?
      changes = persisted_attributes.diff(attributes, type: :persisted)
      changes.any? do |_, attributes|
        !attributes.to_a.reject(&:virtual).empty?
      end
    end

    def clone_to(model)
      clone = ::Blueprint.new(model, **self.options)
      self.configs.each do |config|
        clone.execute(&config)
      end
      model.instance_variable_set :@_blueprint, clone
      Blueprint.models += [model]
    end

    def persisted_attributes
      Blueprint::Attributes.new
    end

    def set_model(model)
      self.model = model
    end

    def table_name
      model.table_name
    end

    def table_exists?
      model.table_exists?
    end

    def transformer
      self.class
    end

    def method_missing(type, name, **options)
      @attributes.add name: name.to_sym, type: type, **options
    end
  end
end
