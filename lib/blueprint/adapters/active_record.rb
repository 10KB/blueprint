module Blueprint
  module Adapters
    class ActiveRecord < ::Blueprint::Base
      class << self
        def applicable?(model)
          return false unless defined?(::ActiveRecord)
          model < ::ActiveRecord::Base
        end
      end
    end
  end
end