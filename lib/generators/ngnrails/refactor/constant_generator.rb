module Ngnrails
  module Refactor
    class ConstantGenerator < Rails::Generators::NamedBase

      def check_existing_app
        unless File.exist? "app/controllers/spa/#{singular_name.underscore.downcase}_controller.rb"
          puts "SPA with name #{singular_name} does not exist!"
          exit!
        end

        @ng_app_name = class_name

      end

      def list_options

        constants = []
        constant_lines = []
        lines = File.readlines("app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/app.js")
        lines.each_with_index do |line, index|

          constant_line = line.match(/#{@ng_app_name}.constant\('(.*)',/)

          unless constant_line.blank?
            constant_line.captures
            constants << constant_line[1]
            constant_lines << line
          end

        end

        puts "Constants in #{singular_name} application: "
        constants.each_with_index do |constant, index|

            puts "  " + (index + 1).to_s + ". " + constant
        end

        constant_number = ask("Which constant do you want to refactor? : ").to_i

        if constant_number.between?(1, constants.length)

          chosen_constant = constants[constant_number - 1]
          chosen_constant_line = constant_lines[constant_number - 1]

          # Check if constant exists in modules
          regex = /#{@ng_app_name}.constant\('#{chosen_constant}'.*/

          if File.readlines("app/assets/javascripts/ng/modules/app.js").grep(regex).any?
            puts "Constant #{chosen_constant} under modules already exists!"
            exit
          end

          # Add line
          append_to_file "app/assets/javascripts/ng/modules/app.js" do
            "\n#{chosen_constant_line.gsub(/#{@ng_app_name}/, 'ngnrailsModules')}"
          end

          # Remove line
          gsub_file "app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/app.js", regex, "// Constant #{chosen_constant} moved to modules"

        else
          puts "Please provide a valid number for chosen constant"
          exit
        end
      end

    end
  end
end
