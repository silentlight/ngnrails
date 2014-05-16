module Ngnrails

  # TODO: DO I NEED IT?
  
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

  module Includes
    class AddGenerator < Rails::Generators::Base

      def ask_about_name

        puts "Includes types:"
        puts "  1. Global"
        puts "  2. App specific"

        @include_type = ask("What include type do you want to add? : ").to_i




      end

      def get_remaining_includes

        # Global
        if @include_type == 1

          modules = YAML.load_file('config/ng_modules.yml')
          @sitewide_modules = modules['sitewide']

          puts @sitewide_modules
          puts OPTIONAL_INCLUDES
          @left_includes = []
          OPTIONAL_INCLUDES.each do |include|

            # Check only modules
            if include.key? :module_name
              unless @sitewide_modules.include? include[:module_name]
                @left_includes << include
              end
            end
          end

          @left_includes.each do |include|
            answer = ask("Do you want to install #{include[:bower_name]} package? (Y/n): ").downcase
            if answer == 'y' || answer.blank?
              install_bower_component include
            end
          end

        else
          

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
          # run("bower install #{bower_name} --save")
        end

        # Add asset to sitewide includes (assets pipeline)
        # append_to_file 'app/assets/javascripts/includes.js', "//=require #{asset_name}\n"



        # Add modules to modules.yml
        if module_name

            # Add module to existing ng apps
            files = Dir.glob("app/assets/javascripts/ng/apps/**/app.js")
            files.each do |file|

              puts file
              insert_into_file file, :before => "// Ng modules" do
        "
        '#{module_name}',
        "
              end

            end
        #   if File.exist?('config/ng_modules.yml')
        #
        #     modules = YAML.load_file('config/ng_modules.yml')
        #     modules['sitewide'] << module_name
        #     File.open('config/ng_modules.yml', 'w') do |f|
        #       f.puts modules.to_yaml
        #     end
        #
        #   else
        #     create_file 'config/ng_modules.yml' do
        #       {'sitewide' => [module_name]}.to_yaml
        #     end
        #   end
        end

      end

    end
  end
end
