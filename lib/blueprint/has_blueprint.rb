module Blueprint
  module HasBlueprint
    def has_blueprint
      self.send :include, ::Blueprint::Model
    end
  end
end