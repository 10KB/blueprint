module Whiteprint
  module Model
    extend ActiveSupport::Concern

    class_methods do
      def whiteprint(**options, &block)
        return @_whiteprint unless block

        @_whiteprint ||= ::Whiteprint.new(self, **options)
        @_whiteprint.execute(&block)
      end
      alias_method :schema, :whiteprint

      def inherited(base)
        whiteprint.clone_to(base) if whiteprint
        super
      end
    end

    def self.included(model)
      Whiteprint.models += [model]
      super
    end
  end
end
