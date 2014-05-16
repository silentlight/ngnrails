module Ngnrails
  class FilterGenerator < Rails::Generators::NamedBase

    source_root File.expand_path("../templates", __FILE__)

    def check_existing_app
      unless File.exist? "app/controllers/spa/#{singular_name.underscore.downcase}_controller.rb"
        puts "SPA with name #{singular_name} does not exist!"
        exit!
      end
    end

    def ask_about_name

      @ng_filter_name = ask("What is the filter name? : ")

    end

    def check_existing_filter
        if File.exist? "app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/filters/#{@ng_filter_name.underscore.downcase}.js"
          puts "Filter #{@ng_filter_name} in #{singular_name} application already exists!"
          exit!
        end
    end

    def create_filter_file

      @ng_app_name = class_name
      @module_name = @ng_filter_name.underscore.camelize(:lower)
      template("app/assets/javascripts/ng/apps/filter_template.js.erb", "app/assets/javascripts/ng/apps/#{singular_name.underscore.downcase}/filters/#{@ng_filter_name.underscore.camelize}.js")

    end

  end

end
