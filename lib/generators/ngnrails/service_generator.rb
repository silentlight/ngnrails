module Ngnrails
  class ServiceGenerator < Rails::Generators::NamedBase

    source_root File.expand_path("../templates", __FILE__)

    def check_existing_app
      unless File.exist? "app/controllers/spa/#{singular_name.underscore.downcase}_controller.rb"
        puts "SPA with name #{singular_name} does not exist!"
        exit!
      end
    end

    def ask_about_name

      @ng_service_name = ask("What is the service name? : ")

    end

    def check_existing_service
        if File.exist? "app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/services/#{@ng_service_name.underscore.downcase}.js"
          puts "Service #{@ng_service_name} in #{singular_name} application already exists!"
          exit!
        end
    end

    def create_service_file

      @ng_app_name = class_name
      @module_name = @ng_service_name.underscore.camelize
      @class_name = @ng_service_name.underscore.camelize
      template("app/assets/javascripts/ng/apps/service_template.js.erb", "app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/services/#{@ng_service_name.underscore.camelize}.js")

    end

  end

end
