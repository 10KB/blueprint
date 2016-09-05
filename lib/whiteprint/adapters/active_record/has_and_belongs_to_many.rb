module Whiteprint
  module Adapters
    class ActiveRecord::HasAndBelongsToMany < ActiveRecord
      def self.applicable?(_)
        false
      end

      def changes_tree
        return {} if model.table_exists?
        super
      end

      def changes?
        !model.table_exists?
      end

      def transformer
        self.class.parent
      end
    end
  end
end
