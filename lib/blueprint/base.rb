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

    def changes_tree
      changes = persisted_attributes.diff(attributes, type: :persisted)

      attributes = changes.flat_map do |kind, attributes|
        attributes.to_a.map do |attribute|
          attribute.to_persisted(kind: kind).to_h
        end
      end

      {table_name: table_name, table_exists: table_exists?, attributes: attributes}
    end

    def table_name
      model.table_name
    end

    def table_exists?
      model.table_exists?
    end

    def method_missing(type, name, **options)
      @attributes.add name: name, type: type, **options
    end
  end
end
