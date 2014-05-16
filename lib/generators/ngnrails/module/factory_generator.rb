module Ngnrails
  module Module
    class FactoryGenerator < Rails::Generators::Base

      source_root File.expand_path("../../templates", __FILE__)

      def ask_about_name

        @ng_factory_name = ask("What is the factory name? : ")

      end

      def check_existing_factory
          if File.exist? "app/assets/javascripts/ng/modules/factories/#{@ng_factory_name.underscore.downcase}.js"
            puts "Factory #{@ng_factory_name} under modules already exists!"
            exit!
          end
      end

      def create_factory_file

        @ng_app_name = 'ngnrailsModules'
        @module_name = @ng_factory_name.underscore.camelize(:lower)
        template("app/assets/javascripts/ng/apps/factory_template.js.erb", "app/assets/javascripts/ng/modules/factories/#{@ng_factory_name.underscore.camelize}.js")

      end

    end
  end
end
