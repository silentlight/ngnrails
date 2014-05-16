module Ngnrails
  module Refactor
    class ValueGenerator < Rails::Generators::NamedBase

      def check_existing_app
        unless File.exist? "app/controllers/spa/#{singular_name.underscore.downcase}_controller.rb"
          puts "SPA with name #{singular_name} does not exist!"
          exit!
        end

        @ng_app_name = class_name

      end

      def list_options

        values = []
        value_lines = []
        lines = File.readlines("app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/app.js")
        lines.each_with_index do |line, index|

          value_line = line.match(/#{@ng_app_name}.value\('(.*)',/)

          unless value_line.blank?
            value_line.captures
            values << value_line[1]
            value_lines << line
          end

        end

        puts "Values in #{singular_name} application: "
        values.each_with_index do |value, index|

            puts "  " + (index + 1).to_s + ". " + value
        end

        value_number = ask("Which value do you want to refactor? : ").to_i

        if value_number.between?(1, values.length)

          chosen_value = values[value_number - 1]
          chosen_value_line = value_lines[value_number - 1]

          # Check if value exists in modules
          regex = /#{@ng_app_name}.value\('#{chosen_value}'.*/

          if File.readlines("app/assets/javascripts/ng/modules/app.js").grep(regex).any?
            puts "Value #{chosen_value} under modules already exists!"
            exit
          end

          # Add line
          append_to_file "app/assets/javascripts/ng/modules/app.js" do
            "\n#{chosen_value_line.gsub(/#{@ng_app_name}/, 'ngnrailsModules')}"
          end

          # Remove line
          gsub_file "app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/app.js", regex, "// Value #{chosen_value} moved to modules"

        else
          puts "Please provide a valid number for chosen value"
          exit
        end
      end

    end
  end
end
