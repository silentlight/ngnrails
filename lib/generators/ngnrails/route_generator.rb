module Ngnrails
  class RouteGenerator < Rails::Generators::NamedBase

    VIEW_TYPE_DYNAMIC = 1
    VIEW_TYPE_STATIC = 2

    attr_accessor :ng_app_name, :ng_route, :ng_controller_name, :ng_view_name, :ng_view_type

    source_root File.expand_path("../templates", __FILE__)

    def check_existing
        unless File.exist? "app/controllers/spa/#{singular_name.underscore.downcase}_controller.rb"
          puts "SPA with name #{singular_name} does not exist!"
          puts "To create SPA please use command: rails g ngnrails:spa #{singular_name.underscore.downcase}"
          exit!
        end
    end

    def ask_about_route

      @ng_route = ask("What is the route url? (ex. log-in): ")

    end

    def ask_about_controller

      @ng_controller_name = ask("What is the controller name? (ex. LogInCtrl): ")

    end

    def ask_about_view

      @ng_view_name = ask("What is the view name? (ex. log-in): ")
      @ng_view_type = ask("Choose option:\n 1.Dynamic\n 2.Static\nDo you want to create dynamic or static view?: ").to_i
    end

    def add_ng_route

      if @ng_view_type == VIEW_TYPE_DYNAMIC
        view_name = @ng_view_name.underscore.dasherize.downcase
      else
        view_name = "#{@ng_view_name.underscore.downcase}.html"
      end

      insert_into_file "app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/app.js", :before => ".otherwise({" do
    ".when('/#{@ng_route}', {
        title: '#{human_name}',
        templateUrl: '/ng/apps/#{singular_name.underscore.downcase}/views/#{view_name}',
        controller: '#{@ng_controller_name.underscore.camelize}'
    })\n    "
      end
    end

    def create_ng_controller

      @ng_app_name = class_name
      @module_name = @ng_controller_name.underscore.camelize
      template("app/assets/javascripts/ng/apps/controller_template.js.erb", "app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/controllers/#{@ng_controller_name}.js")

    end

    def create_ng_view

      if @ng_view_type == VIEW_TYPE_DYNAMIC

        # Add route
        insert_into_file "config/routes.rb", :after => "# Ng::Apps::#{class_name}::Views\n" do
          "
          get '#{@ng_view_name.underscore.dasherize.downcase}' => 'views##{@ng_view_name.underscore.downcase}'
          "
        end

        # Add controller action
        insert_into_file "app/controllers/ng/apps/#{singular_name.underscore.downcase}/views_controller.rb", :after => "# View actions\n" do
"  def #{@ng_view_name.underscore.downcase}
    @app_name = '#{human_name} | #{@ng_route.underscore.dasherize.downcase}'
  end\n\n"
        end

        # Add view file
        copy_file "app/views/ng/apps/views/dynamic_view_example.html.erb", "app/views/ng/apps/#{singular_name.underscore.downcase}/views/#{ng_view_name.underscore.downcase}.html.erb"

      else
        copy_file "public/ng/apps/views/static_view_example.html", "public/ng/apps/#{singular_name.underscore.downcase}/views/#{ng_view_name.underscore.downcase}.html"
      end

    end
  end

end
