module Whiteprint
  module Plugins
    module Accessor
      def accessor(name, options)
        @attributes.add(name: name, type: :accessor, virtual: true, **options)
        model.send :attr_accessor, name
      end
    end
  end
end
