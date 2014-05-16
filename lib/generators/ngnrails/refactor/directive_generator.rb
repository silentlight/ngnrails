module Ngnrails
  module Refactor

    class DirectiveGenerator < Rails::Generators::NamedBase

      VIEW_TYPE_DYNAMIC = 1
      VIEW_TYPE_STATIC = 2

      attr_accessor :ng_directive_name, :ng_view_name, :ng_view_type

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

        files = Dir.glob("app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/directives/*.js")
        puts "Directives in #{singular_name} application: "
        files.each_with_index do |file, index|

          puts "  " + (index + 1).to_s + ". " + File.basename( file, ".*" )

        end

        directive_number = ask("Which directive do you want to refactor? : ").to_i

        if directive_number.between?(1, files.length)

          @ng_directive_path = files[(directive_number - 1)]
          @ng_directive_name = File.basename(@ng_directive_path, ".*")
          @ng_directive_filename = File.basename(@ng_directive_path)

          # Check if directive exists in modules
          if File.exist? "app/assets/javascripts/ng/modules/directives/#{@ng_directive_filename}"
            puts "Directive #{@ng_directive_name} already exists in modules directory"
            exit
          end

          # Check if directive has a template
          @old_template_url = nil

          lines = File.readlines(@ng_directive_path)
          lines.each_with_index do |line, index|

            # Get templateUrl line
            template_line = line.match(/templateUrl:\s*'(.*)'/)
            unless template_line.blank?
              template_line.captures
              @old_template_url = template_line[1]
            end

            # Get restrict line
            restrict_line = line.match(/restrict:\s*'(.*)'/)
            unless restrict_line.blank?
              restrict_line.captures
              @restrict = restrict_line[1]
            end
          end

          # Directive has a template
          if @old_template_url

            # Check if static or dynamic template
            if @old_template_url.include? ".html"
              # STATIC

              # Copy template file to public directory
              filename = File.basename @old_template_url

              @old_template_path = "public/ng/apps/#{singular_name.underscore.downcase}/templates/directives/#{@ng_directive_name.underscore.downcase}/#{filename}"
              @new_template_path = "public/ng/modules/templates/directives/#{@ng_directive_name.underscore.downcase}/#{filename}"
              copy_file @old_template_path, @new_template_path

              # Replace directive js templateUrl
              @new_template_url = "/ng/modules/templates/directives/#{@ng_directive_name.underscore.downcase}/#{filename}"

              gsub_file @ng_directive_path, @old_template_url, @new_template_url

              # Delete old template file
              remove_file @old_template_url

            else
              # DYNAMIC

              route_ending = ""
              route_ending += @old_template_url

              route_ending.slice! "/ng/apps/admin_app/templates/directives/"

              # Replace directive js templateUrl
              @new_template_url = "/ng/modules/templates/directives/#{route_ending}"

              gsub_file @ng_directive_path, @old_template_url, @new_template_url

              route_found = false
              lines = File.readlines("config/routes.rb")
              lines.each_with_index do |line, index|

                route_line_parts = route_ending.split("/")
                controller_url = route_line_parts[0]
                route_line = line.match(/get\s*'#{controller_url}.*/)

                unless route_line.blank?


                  line_replace_answer = ask("Do you want to replace route #{route_line} on line #{(index + 1)}? (Y/n): ").downcase

                  if line_replace_answer.blank? || line_replace_answer == 'y'

                    route_found = true

                    # Remove old route
                    gsub_file "config/routes.rb", route_line.to_s, "# Route #{route_ending} moved to modules"

                    # Add new route
                    insert_into_file "config/routes.rb", :after => "# Ng::Modules::Templates::Directives\n" do
            "
            #{route_line}
            "
                    end
                  end
                end
              end

              if route_found

                # Move controller
                @old_controller_path = "app/controllers/ng/apps/#{singular_name.underscore.downcase}/templates/directives/#{@ng_directive_name.underscore.downcase}_controller.rb"
                @new_controller_path = "app/controllers/ng/modules/templates/directives/#{@ng_directive_name.underscore.downcase}_controller.rb"
                copy_file @old_controller_path, @new_controller_path

                # Replace controller's namespace
                gsub_file @new_controller_path, "Apps::#{class_name}", "Modules"

                # Delete old controller
                remove_file @old_controller_path

                # Move view files
                @old_views_dir = "app/views/ng/apps/#{singular_name.underscore.downcase}/templates/directives/#{@ng_directive_name.underscore.downcase}"
                @new_views_dir = "app/views/ng/modules/templates/directives/#{@ng_directive_name.underscore.downcase}"
                directory @old_views_dir, @new_views_dir

                # Remove old views dir
                remove_dir @old_views_dir

              else
                puts "No routes have been found for directive #{@ng_directive_name.underscore.downcase}. Directive cannot be refactored."
                exit
              end

            end

          end

          # Copy js file
          @ng_directive_new_path = "app/assets/javascripts/ng/modules/directives/#{@ng_directive_filename}"
          copy_file @ng_directive_path, @ng_directive_new_path

          # Change app name
          gsub_file(@ng_directive_new_path, /#{@ng_app_name}/, 'ngnrailsModules')

          # Delete old js file
          remove_file @ng_directive_path

        else
          puts "Please provide a valid number for chosen directive"
          exit
        end

      end

      def print_instructions

        puts "--------------------------------------"
        puts "-----------------USAGE----------------"
        puts "To add directive to your views use:"
        case @restrict
          when 'A'
            puts "<div #{@ng_directive_name.underscore.dasherize.downcase}></div>"
          when 'E'
            puts "<#{@ng_directive_name.underscore.dasherize.downcase}></#{@ng_directive_name.underscore.dasherize.downcase}>"
          when 'C'
            puts "<div class=\"#{@ng_directive_name.underscore.dasherize.downcase};\"></div>"
          when 'M'
            puts "<!-- directive: #{@ng_directive_name.underscore.dasherize.downcase} -->"
          else
            puts "Something went wrong. Directive cannot be used."
        end
        puts "--------------------------------------"

      end
    end
  end

end
