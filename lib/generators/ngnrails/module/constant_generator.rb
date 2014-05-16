module Ngnrails
  module Module
    class ConstantGenerator < Rails::Generators::Base

      def ask_about_name

        @ng_constant_name = ask("What is the name? : ")

      end

      def check_existing_value

        regex = /#{@ng_app_name}.constant\('#{@ng_constant_name}'/
        if File.readlines("app/assets/javascripts/ng/modules/app.js").grep(regex).any?
          puts "Value #{@ng_constant_name} under modules already exists!"
          exit!
        end
      end

      def ask_about_value

        @ng_constant_value = ask("What is the value? : ")

      end


      def create_service_file

        @ng_app_name = 'ngnrailsModules'

        append_to_file "app/assets/javascripts/ng/modules/app.js" do
          "\n#{@ng_app_name}.constant('#{@ng_constant_name}', '#{@ng_constant_value}');"
        end

      end

    end
  end

end
