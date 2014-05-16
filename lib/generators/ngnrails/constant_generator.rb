module Ngnrails
  class ConstantGenerator < Rails::Generators::NamedBase

    def check_existing_app
      unless File.exist? "app/controllers/spa/#{singular_name.underscore.downcase}_controller.rb"
        puts "SPA with name #{singular_name} does not exist!"
        exit!
      end

      @ng_app_name = class_name

    end

    def ask_about_name

      @ng_constant_name = ask("What is the name? : ")

    end

    def check_existing_value

      regex = /#{@ng_app_name}.constant\('#{@ng_constant_name}'/
      if File.readlines("app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/app.js").grep(regex).any?
        puts "Constant #{@ng_constant_name} in #{singular_name} application already exists!"
        exit!
      end
    end

    def ask_about_value

      @ng_constant_value = ask("What is the value? : ")

    end

    def create_service_file

      append_to_file "app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/app.js" do
        "\n#{@ng_app_name}.constant('#{@ng_constant_name}', '#{@ng_constant_value}');"
      end

    end

  end

end
