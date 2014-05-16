module Ngnrails
  class FactoryGenerator < Rails::Generators::NamedBase

    source_root File.expand_path("../templates", __FILE__)

    def check_existing_app
      unless File.exist? "app/controllers/spa/#{singular_name.underscore.downcase}_controller.rb"
        puts "SPA with name #{singular_name} does not exist!"
        exit!
      end
    end

    def ask_about_name

      @ng_factory_name = ask("What is the factory name? : ")

    end

    def check_existing_factory
        if File.exist? "app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/factories/#{@ng_factory_name.underscore.downcase}.js"
          puts "Factory #{@ng_factory_name} in #{singular_name} application already exists!"
          exit!
        end
    end

    def create_factory_file

      @ng_app_name = class_name
      @module_name = @ng_factory_name.underscore.camelize(:lower)
      template("app/assets/javascripts/ng/apps/factory_template.js.erb", "app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/factories/#{@ng_factory_name.underscore.camelize}.js")

    end

  end

end
