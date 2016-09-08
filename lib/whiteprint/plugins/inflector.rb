module Whiteprint
  module Plugins
    module Inflector
      extend ActiveSupport::Concern

      class_methods do
        def underscore(name)
          name = name.tr(' ', '_')
          name.gsub(/([a-z])([A-Z])/) { "#{Regexp.last_match[1]}_#{Regexp.last_match[2].downcase}" }.downcase
        end

        def camelize(name)
          underscore(name).split('_').collect(&:capitalize).join
        end
      end
    end
  end
end
