module Whiteprint
  module HasWhiteprint
    def has_whiteprint
      send :include, ::Whiteprint::Model
    end
  end
end
