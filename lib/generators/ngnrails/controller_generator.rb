module Ngnrails
  class ControllerGenerator < Rails::Generators::NamedBase

    source_root File.expand_path("../templates", __FILE__)

    def check_existing_app
      unless File.exist? "app/controllers/spa/#{singular_name}_controller.rb"
        puts "SPA with name #{singular_name} does not exist!"
        exit!
      end
    end

    def ask_about_name

      @ng_controller_name = ask("What is the controller name? : ")

    end

    def check_existing_service
        if File.exist? "app/assets/javascripts/ng/apps/#{singular_name}/controllers/#{@ng_controller_name.underscore.downcase}.js"
          puts "Controller #{@ng_controller_name} in #{singular_name} application already exists!"
          exit!
        end
    end

    def create_service_file

      @ng_app_name = class_name
      @module_name = @ng_controller_name.underscore.camelize
      template("app/assets/javascripts/ng/apps/controller_template.js.erb", "app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/controllers/#{@ng_controller_name.underscore.camelize}.js")

    end

  end

end
