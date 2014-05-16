module Ngnrails
  module Module
    class ControllerGenerator < Rails::Generators::Base

      source_root File.expand_path("../../templates", __FILE__)

      def ask_about_name

        @ng_controller_name = ask("What is the controller name? : ")

      end

      def check_existing_service
          if File.exist? "app/assets/javascripts/ng/modules/controllers/#{@ng_controller_name.underscore.downcase}.js"
            puts "Controller #{@ng_controller_name} under modules already exists!"
            exit!
          end
      end

      def create_service_file

        @ng_app_name = 'ngnrailsModules'
        @module_name = @ng_controller_name.underscore.camelize
        template("app/assets/javascripts/ng/apps/controller_template.js.erb", "app/assets/javascripts/ng/modules/controllers/#{@ng_controller_name.underscore.camelize}.js")

      end

    end
  end
end
