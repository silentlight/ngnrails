module Ngnrails
  module Refactor
    class ControllerGenerator < Rails::Generators::NamedBase

      source_root File.expand_path("../../../../../", __FILE__)

      def define_app_name
        @ng_app_name = class_name
      end

      def check_existing_app
        unless File.exist? "app/controllers/spa/#{singular_name.underscore.downcase}_controller.rb"
          puts "SPA with name #{singular_name} does not exist!"
          exit!
        end
      end

      def list_options

        files = Dir.glob("app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/controllers/*.js")
        puts "Controller in #{singular_name} application: "
        files.each_with_index do |file, index|

          puts "  " + (index + 1).to_s + ". " + File.basename( file, ".*" )

        end

        controller_number = ask("Which controller do you want to refactor? : ").to_i

        if controller_number.between?(1, files.length)

          @ng_controller_path = files[(controller_number - 1)]
          @ng_controller_name = File.basename(@ng_controller_path, ".*")
          @ng_controller_filename = File.basename(@ng_controller_path)
          @ng_controller_new_path = "app/assets/javascripts/ng/modules/controllers/#{@ng_controller_filename}"

          # Check if controller exists in modules
          if File.exist? "app/assets/javascripts/ng/modules/controllers/#{@ng_controller_filename}"
            puts "Controller #{@ng_controller_name} already exists in modules directory"
            exit
          end

          # Copy js file
          copy_file @ng_controller_path, @ng_controller_new_path

          # Change app name
          gsub_file(@ng_controller_new_path, /#{@ng_app_name}/, 'ngnrailsModules')

          # Delete old js file
          remove_file @ng_controller_path

        else
          puts "Please provide a valid number for chosen controller"
          exit
        end
      end
    end
  end
end
