module Ngnrails
  module Module
    class DirectiveGenerator < Rails::Generators::Base

      VIEW_TYPE_DYNAMIC = 1
      VIEW_TYPE_STATIC = 2

      attr_accessor :ng_directive_name, :ng_view_name, :ng_view_type

      source_root File.expand_path("../../templates", __FILE__)

      def define_app_name
        @ng_app_name = 'ngnrailsModules'
      end

      def ask_about_name

        @ng_directive_name = ask("What is the directive name? : ")

      end

      def check_existing_directive
        if File.exist? "app/assets/javascripts/ng/modules/directives/#{@ng_directive_name.underscore.downcase}.js"
          puts "Directive #{@ng_directive_name} under modules already exists!"
          exit!
        end
      end

      def create_directive_file

        # Restrict
        restrict = ask("Restrict (A/e/c/m): ").upcase
        @restrict = restrict.blank? ? 'A' : restrict

        # Transclude
        transclude = ask("Transclude (true/FALSE): ").downcase
        if transclude.blank? || transclude == 'false'
          @transclude = false
          @replace = false
        else
          @transclude = true

          # Replace
          replace = ask("Replace (true/FALSE): ").downcase
          if replace.blank? || replace == 'false'
            @replace = false
          else
            @replace = true
          end
        end

        # Template url
        template = ask("Do you want to use a template? (y/N): ").downcase
        if template.blank? || template == 'n'
          @template_url = nil
        else

          template_name = ask("What is the template name? (main): ")
          @template_name = template_name.blank? ? 'main' : template_name
          @template_type = ask("Choose option:\n 1.Dynamic\n 2.Static\nDo you want to create dynamic or static template?: ").to_i

          if @template_type == VIEW_TYPE_DYNAMIC
            template_name = @template_name.underscore.dasherize.downcase
          else
            template_name = "#{@template_name.underscore.downcase}.html"
          end

          @template_url = "/ng/modules/templates/directives/#{@ng_directive_name.underscore.dasherize.downcase}/#{template_name}"
        end

        @module_name = @ng_directive_name.underscore.camelize(:lower)
        template("app/assets/javascripts/ng/apps/directive_template.js.erb", "app/assets/javascripts/ng/modules/directives/#{@ng_directive_name.underscore.camelize}.js")

      end

      def create_ng_view

        if @template_url
          if @template_type == VIEW_TYPE_DYNAMIC

            # Add route
            insert_into_file "config/routes.rb", :after => "# Ng::Modules::Templates::Directives\n" do
              "
              get '#{@ng_directive_name.underscore.dasherize.downcase}/#{@template_name}' => '#{@ng_directive_name.underscore.downcase}##{@template_name.underscore.downcase}'
              "
            end

            # Add controller
            @controller_namespace = "Modules"
            @controller_name = @ng_directive_name.underscore.camelize
            template('app/controllers/ng/apps/directives_controller_template.rb.erb', "app/controllers/ng/modules/templates/directives/#{@ng_directive_name.underscore.downcase}_controller.rb")

            # Add view file
            copy_file "app/views/ng/apps/templates/dynamic_directive_template_example.html.erb", "app/views/ng/modules/templates/directives/#{@ng_directive_name.underscore.downcase}/#{@template_name.underscore.downcase}.html.erb"

          else
            copy_file "public/ng/apps/templates/static_directive_template_example.html", "public/ng/modules/templates/directives/#{@ng_directive_name.underscore.downcase}/#{@template_name.underscore.downcase}.html"
          end
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
