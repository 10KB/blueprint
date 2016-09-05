module Whiteprint
  module Adapters
    class Test < ::Whiteprint::Base
      class << self
        def applicable?(_model)
          false
        end
      end

      def persisted_attributes
        @_persisted_whiteprint.attributes
      end

      def persisted(&block)
        @_persisted_whiteprint ||= Whiteprint::Base.new(@model)
        @_persisted_whiteprint.instance_eval(&block)
      end
    end
  end
end
