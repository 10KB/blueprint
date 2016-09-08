module Whiteprint
  module Plugins
    Dir[File.dirname(__FILE__) + '/plugins/*.rb'].each do |plugin|
      require plugin
      name = File.basename(plugin, '.rb')
      Whiteprint.register_plugin name.to_sym, const_get(name.split('_').collect(&:capitalize).join)
    end
  end
end
