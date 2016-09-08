module Whiteprint
  module Plugins
    module References
      BELONGS_TO_OPTIONS = [:class_name, :anonymous_class, :foreign_key, :validate, :autosave,
                            :dependent, :primary_key, :inverse_of, :required, :foreign_type,
                            :polymorphic, :touch, :counter_cache, :cached]

      def references(name, **options)
        super
        return unless @auto_belongs_to
        model.send :belongs_to, name.to_sym, **options.slice(*BELONGS_TO_OPTIONS)
      end
    end
  end
end
