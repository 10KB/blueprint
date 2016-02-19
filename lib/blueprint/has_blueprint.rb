module Blueprint
  module HasBlueprint
    def has_blueprint
      send :include, ::Blueprint::Model
    end
  end
end
