module Ngnrails
  class SpaGenerator < Rails::Generators::NamedBase

    VIEW_TYPE_DYNAMIC = 1
    VIEW_TYPE_STATIC = 2

    attr_accessor :with_example, :view_type, :view_route,
                  :ng_app_name, :ng_controller_name,
                  :sitewide_modules

    source_root File.expand_path("../templates", __FILE__)

    def check_existing
        if File.exist? "app/controllers/spa/#{singular_name.underscore.downcase}_controller.rb"
          puts "SPA with name #{singular_name} already exist!"
          exit!
        end
    end

    def ask_about_example
      with_example_answer = ask("Do you want to create an example controller? (Y/n): ")

      @with_example = with_example_answer.downcase == 'y' || with_example_answer.blank? ? TRUE : FALSE

    end

    def ask_about_view

      @view_type = ask("Choose option:\n 1.Dynamic\n 2.Static\nDo you want to create dynamic or static view?: ").to_i if with_example

    end

    def modify_routes_file

      if @with_example
        example_view = "get 'main' => 'views#main'"
      else
        example_view = ""
      end

      main_route_answer = ask("What is the main route for this SPA? (#{singular_name.dasherize.underscore}): ")

      @main_route = main_route_answer.blank? ? singular_name.dasherize.underscore : main_route_answer

      insert_into_file "config/routes.rb", :after => "API::Application.routes.draw do\n" do
"
  # SPA - Single page applications
  get '#{@main_route}' => 'spa/#{singular_name.underscore.downcase}#index', as: :#{singular_name.underscore.downcase}
"
      end

      insert_into_file "config/routes.rb", :after => "# Ng::Apps\n" do
        "
      namespace :#{singular_name.underscore.downcase} do
        scope :views do
          # Ng::Apps::#{class_name}::Views

          #{example_view}

        end
        namespace :templates do
          namespace :directives do
          # Ng::Apps::#{class_name}::Templates::Directives

          end
        end
      end
        "
      end


    end

    def create_rails_layout

      new_rails_layout_answer = ask("Do you want to create a separate Rails layout for this SPA? (y/N): ").downcase
      if !new_rails_layout_answer.blank? && new_rails_layout_answer == 'y'

        @rails_layout_file = 'ng_example'

        text = File.read(File.expand_path("../templates", __FILE__) + '/app/views/layouts/template.html.erb.tt')
        text = text.gsub(/@@singular_name@@/, singular_name.underscore.downcase)
        text = text.gsub(/@@human_name@@/, human_name)

        create_file "app/views/layouts/#{singular_name}.html.erb", text

      end
    end

    def create_spa_index_view
      text = File.read(File.expand_path("../templates", __FILE__) + '/app/views/spa/index_template.html.erb.tt')

      @rails_layout_file = singular_name.underscore.downcase if @rails_layout_file.blank?

      text = text.gsub(/@@layout_file@@/, @rails_layout_file)
      text = text.gsub(/@@singular_name@@/, singular_name.underscore.downcase)
      text = text.gsub(/@@class_name@@/, class_name)

      create_file "app/views/spa/#{singular_name.underscore.downcase}/index.html.erb", text
    end

    def create_views_structure

      empty_directory "app/views/ng/apps/#{singular_name.underscore.downcase}/views"

    end

    def create_controllers

      # Main SPA controller
      template('app/controllers/spa/controller_template.rb.erb', "app/controllers/spa/#{singular_name.underscore.downcase}_controller.rb")

      # Views controller
      template('app/controllers/ng/apps/views_controller_template.rb.erb', "app/controllers/ng/apps/#{singular_name.underscore.downcase}/views_controller.rb")

    end

    def create_javascript_files

      # Create app specific includes (assets pipeline)
      create_file "app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/includes.js", "//= require_tree ."

      empty_directory "app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/controllers"
      empty_directory "app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/directives"
      empty_directory "app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/factories"
      empty_directory "app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/filters"
      empty_directory "app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/services"

      if @view_type == VIEW_TYPE_DYNAMIC
        @view_route = "/ng/apps/admin_app/views/main"
      else
        @view_route = "ng/apps/admin_app/views/main.html"
      end

      @ng_app_name = singular_name.underscore.camelize
      modules = YAML.load_file('config/ng_modules.yml')
      @sitewide_modules = modules['sitewide']

      template("app/assets/javascripts/ng/apps/app_template.js.erb", "app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/app.js")

    end

    def create_example

      if @with_example

        @ng_app_name = class_name
        @ng_controller_name = @module_name = "MainCtrl"

        # Create ng controller
        template("app/assets/javascripts/ng/apps/controller_template.js.erb", "app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/controllers/#{@ng_controller_name}.js")

        # Create ng view
        if @view_type == VIEW_TYPE_DYNAMIC
          copy_file "app/views/ng/apps/views/dynamic_view_example.html.erb", "app/views/ng/apps/#{singular_name.underscore.downcase}/views/main.html.erb"
        else
          copy_file "public/ng/apps/views/static_view_example.html", "public/ng/apps/#{singular_name.underscore.downcase}/views/main.html"
        end


      end

    end

  end

end
