module Ngnrails
  module Module
    class ServiceGenerator < Rails::Generators::Base

      attr_accessor :ng_app_name, :module_name

      source_root File.expand_path("../../templates", __FILE__)

      def ask_about_name

        @ng_service_name = ask("What is the service name? : ")

      end

      def check_existing_service
          if File.exist? "app/assets/javascripts/ng/modules/services/#{@ng_service_name.underscore.downcase}.js"
            puts "Service #{@ng_service_name} under modules already exists!"
            exit!
          end
      end

      def create_service_file

        @ng_app_name = 'ngnrailsModules'
        @module_name = @ng_service_name.underscore.camelize
        @class_name = @ng_service_name.underscore.camelize
        template("app/assets/javascripts/ng/apps/service_template.js.erb", "app/assets/javascripts/ng/modules/services/#{@ng_service_name.underscore.camelize}.js")

      end

    end
  end
end
