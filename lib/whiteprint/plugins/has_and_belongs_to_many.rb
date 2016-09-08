module Whiteprint
  module Plugins
    module HasAndBelongsToMany
      extend ActiveSupport::Concern

      class HasAndBelongsToManyModel
        class << self
          def setup(association: association)
            include Whiteprint::Model
            @join_table = association.join_table

            whiteprint(adapter: :has_and_belongs_to_many, id: false, timestamps: false) do
              integer association.foreign_key
              integer association.association_foreign_key
            end
          end

          def name
            "#{@join_table}_habtm_model"
          end

          def table_name
            @join_table
          end

          def table_exists?
            ::ActiveRecord::Base.connection.table_exists?(table_name)
          end
        end
      end

      def has_and_belongs_to_many(name, **options)
        super(name, **options.merge(virtual: true))

        model.send(:has_and_belongs_to_many, name.to_sym, **options) unless model.reflect_on_association(name)
        association = model.reflect_on_association(name)

        Class.new(HasAndBelongsToManyModel) do
          setup association: association
        end
      end
      alias_method :habtm, :has_and_belongs_to_many
    end
  end
end
