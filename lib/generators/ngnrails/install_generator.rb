module Ngnrails

  # Provide :asset_name if the asset name is different than :bower_name
  REQUIRED_INCLUDES = [
      {bower_name: 'jquery'},
      {bower_name: 'angular'}
  ]

  # If include is a Angular module provide :module_name key to hash
  OPTIONAL_INCLUDES = [
      {bower_name: 'underscore'},
      {bower_name: 'angular-resource', module_name: 'ngResource'},
      {bower_name: 'angular-route', module_name: 'ngRoute'},
      {bower_name: 'angular-mocks', module_name: 'ngMocks'},
      {bower_name: 'angular-cookies', module_name: 'ngCookies'},
      {bower_name: 'angular-animate', module_name: 'ngAnimate'},
      {bower_name: 'angular-sanitize', module_name: 'ngSanitize'}
  ]

  class InstallGenerator < Rails::Generators::Base

    attr_accessor :name, :version, :description, :license, :homepage, :private

    source_root File.expand_path("../templates", __FILE__)

    def create_assets_structure

      # Create structure in app/assets/javascripts/ng
      empty_directory "app/assets/javascripts/ng/apps"
      empty_directory "app/assets/javascripts/ng/modules/directives"
      empty_directory "app/assets/javascripts/ng/modules/factories"
      empty_directory "app/assets/javascripts/ng/modules/filters"
      empty_directory "app/assets/javascripts/ng/modules/services"
      copy_file "app/assets/javascripts/ng/modules/app.js", "app/assets/javascripts/ng/modules/app.js"

      # Create sitewide includes (assets pipeline)
      create_file "app/assets/javascripts/includes.js"

      # Add asset to modules/shared includes (assets pipeline)
      append_to_file 'app/assets/javascripts/ng/modules/includes.js', "//=require_tree .\n"

    end

    def setup_bower

      use_bower_answer = ask("Do you want to use Bower for assets package management? (Y/n): ").downcase

      if use_bower_answer.downcase == 'y' || use_bower_answer.blank?

        # Create directory for Bower packages
        empty_directory "vendor/assets/bower_components"

        # Add config options
        insert_into_file "config/application.rb", :after => "class Application < Rails::Application\n" do
          "    \n
               # Used by Ngnrails with Bower integration\n
               config.assets.paths << Rails.root.join('vendor', 'assets', 'bower_components')\n
          "
        end

        # Create .bowerrc file
        copy_file ".bowerrc", ".bowerrc"

        # Create bower.json file
        @name = ask('What is the application name?: ')

        version = ask('What is the application version? (0.0.0): ')
        @version = version.blank? ? '0.0.0' : version

        @description = ask('Who is the application description?: ')

        license = ask('Who is the application license? (MIT): ')
        @license = license.blank? ? 'MIT' : license

        @homepage = ask('What is the main website of the application?: ')

        @private = ask('Would you like to mark this package as private which prevents it from being accidentally published to the registry? (Y/N): ').downcase

        template('bower_template.json.erb', 'bower.json')

      end


    end

    def setup_sitewide_includes

      # -- INSTALL REQUIRED INCLUDES
      Ngnrails::REQUIRED_INCLUDES.each do |include|
        install_bower_component include
      end

      # -- INSTALL OPTIONAL INCLUDES
      Ngnrails::OPTIONAL_INCLUDES.each do |include|
        answer = ask("Do you want to install #{include[:bower_name]} package? (Y/n): ").downcase
        if answer == 'y' || answer.blank?
          install_bower_component include
        end
      end

    end

    def create_rails_example_layout

      unless File.exist? "app/views/layouts/ng_example.html.erb"
        copy_file "app/views/layouts/example.html.erb", "app/views/layouts/ng_example.html.erb"
      end

    end

    def create_controllers_structure

      # Create structure in app/assets/javascripts/ng
      empty_directory "app/controllers/api/v1"
      copy_file "app/controllers/api/base_controller.rb", "app/controllers/api/base_controller.rb"
      copy_file "app/controllers/spa/base_controller.rb", "app/controllers/spa/base_controller.rb"
      copy_file "app/controllers/ng/base_controller.rb", "app/controllers/ng/base_controller.rb"
      empty_directory "app/controllers/ng/modules/directives"
      empty_directory "app/controllers/ng/modules/factories"
      empty_directory "app/controllers/ng/modules/filters"
      empty_directory "app/controllers/ng/modules/services"
    end

    def create_form_builder

      copy_file "app/form_builders/ng/form_builder.rb", "app/form_builders/ng/form_builder.rb"

    end

    def create_helper

      copy_file "app/helpers/ng_helper.rb", "app/helpers/ng_helper.rb"

    end

    def create_views_structure

      empty_directory "app/views/api/v1"
      empty_directory "app/views/ng/apps"
      empty_directory "app/views/ng/modules/directives"
      empty_directory "app/views/ng/modules/factories"
      empty_directory "app/views/ng/modules/filters"
      empty_directory "app/views/ng/modules/services"

    end

    def create_api_constraints

      copy_file "lib/api_constraints.rb", "lib/api_constraints.rb"

    end

    def modify_routes_file

      # Include ApiConstraints in routes
      prepend_to_file 'config/routes.rb' do
        "require 'api_constraints'\n"
      end


      insert_into_file "config/routes.rb", :after => "API::Application.routes.draw do\n" do
"
  # API
  namespace :api, defaults: {format: :json} do
    scope module: 'v1', constraints: ApiConstraints.new(version: 1, default: true) do

      # Example: resources :support_tickets, only: [:create]

    end

  end

  # AngularJS dynamic views and templates
  namespace :ng, defaults: {format: :html} do
    namespace :apps do
      # Ng::Apps

    end
    namespace :modules do
      namespace :templates do
        namespace :directives do
          # Ng::Modules::Templates::Directives

        end
      end
      namespace :templates do
        namespace :factories do
          # Ng::Modules::Templates::Factories

        end
      end
      namespace :templates do
        namespace :filters do
          # Ng::Modules::Templates::Filters

        end
      end
      namespace :templates do
        namespace :services do
          # Ng::Modules::Templates::Services

        end
      end
    end
  end\n
"
      end

    end

    private

    # TODO: Refactor to separate module
    def install_bower_component(include)

      bower_name  = include[:bower_name]
      asset_name  = include[:asset_name] || nil
      module_name = include[:module_name] || nil

      asset_name = asset_name.blank? ? bower_name : asset_name

      # Install bower package
      in_root do
        run("bower install #{bower_name} --save")
      end

      # Add asset to sitewide includes (assets pipeline)
      append_to_file 'app/assets/javascripts/includes.js', "//=require #{asset_name}\n"

      # Add modules to modules.yml
      if module_name

        if File.exist?('config/ng_modules.yml')

          modules = YAML.load_file('config/ng_modules.yml')
          modules['sitewide'] << module_name
          File.open('config/ng_modules.yml', 'w') do |f|
            f.puts modules.to_yaml
          end

        else
          create_file 'config/ng_modules.yml' do
            {'sitewide' => [module_name]}.to_yaml
          end
        end
      end

    end

  end
end
