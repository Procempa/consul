module Consul
  class Application < Rails::Application
    config.i18n.default_locale = 'pt-BR'
    config.i18n.available_locales = ['pt-BR', :es, :en]        
    config.time_zone = 'Brasilia'
  end
end