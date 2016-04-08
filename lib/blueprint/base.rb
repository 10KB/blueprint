module Blueprint
  class Base
    attr_accessor :model, :attributes

    class << self
      def applicable?(_)
        true
      end
    end

    def initialize(model, **_options)
      self.model                 = model
      self.attributes            = Attributes.new
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
      changes = persisted_attributes.diff(attributes, type: :persisted)

      attributes = changes.flat_map do |kind, changed_attributes|
        changed_attributes.to_a.map do |attribute|
          next if attribute.virtual
          attribute.for_persisted(kind: kind).to_h
        end.compact
      end

      { table_name: table_name, table_exists: table_exists?, attributes: attributes }
    end

    def changes?
      changes = persisted_attributes.diff(attributes, type: :persisted)
      changes.any? do |_, attributes|
        !attributes.to_a.reject(&:virtual).empty?
      end
    end

    def persisted_attributes
      Blueprint::Attributes.new
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
