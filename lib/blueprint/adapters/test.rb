module Blueprint
  module Adapters
    class Test < ::Blueprint::Base
      class << self
        def applicable?(model)
          false
        end
      end

      def persisted_attributes
        @_persisted_blueprint.attributes
      end

      def persisted(&block)
        @_persisted_blueprint ||= Blueprint::Base.new(@model)
        @_persisted_blueprint.instance_eval(&block)
      end
    end
  end
end
