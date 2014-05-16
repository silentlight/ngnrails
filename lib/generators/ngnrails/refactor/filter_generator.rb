module Ngnrails
  module Refactor
    class FilterGenerator < Rails::Generators::NamedBase

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

        files = Dir.glob("app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/filters/*.js")
        puts "Filter in #{singular_name} application: "
        files.each_with_index do |file, index|

          puts "  " + (index + 1).to_s + ". " + File.basename( file, ".*" )

        end

        filter_number = ask("Which filter do you want to refactor? : ").to_i

        if filter_number.between?(1, files.length)

          @ng_filter_path = files[(filter_number - 1)]
          @ng_filter_name = File.basename(@ng_filter_path, ".*")
          @ng_filter_filename = File.basename(@ng_filter_path)
          @ng_filter_new_path = "app/assets/javascripts/ng/modules/filters/#{@ng_filter_filename}"

          # Check if filter exists in modules
          if File.exist? "app/assets/javascripts/ng/modules/filters/#{@ng_filter_filename}"
            puts "Filter #{@ng_filter_name} already exists in modules directory"
            exit
          end

          # Copy js file
          copy_file @ng_filter_path, @ng_filter_new_path

          # Change app name
          gsub_file(@ng_filter_new_path, /#{@ng_app_name}/, 'ngnrailsModules')

          # Delete old js file
          remove_file @ng_filter_path

        else
          puts "Please provide a valid number for chosen filter"
          exit
        end
      end
    end
  end
end
