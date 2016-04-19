module Blueprint
  module Model
    extend ActiveSupport::Concern

    class_methods do
      def blueprint(**options, &block)
        return @_blueprint unless block

        @_blueprint ||= ::Blueprint.new(self, **options)
        @_blueprint.instance_eval(&block)
      end
      alias_method :schema, :blueprint

      def inherited(base)
        base.instance_variable_set(:@_blueprint, @_blueprint.dup) if @_blueprint
        Blueprint.models += [base]
        super
      end
    end

    def self.included(model)
      Blueprint.models += [model]
      super
    end
  end
end
