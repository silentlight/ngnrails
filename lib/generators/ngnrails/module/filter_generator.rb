module Ngnrails
  module Module
    class FilterGenerator < Rails::Generators::Base

      source_root File.expand_path("../../templates", __FILE__)

      def ask_about_name

        @ng_filter_name = ask("What is the filter name? : ")

      end

      def check_existing_filter
          if File.exist? "app/assets/javascripts/ng/modules/filters/#{@ng_filter_name.underscore.downcase}.js"
            puts "Filter #{@ng_filter_name} under modules application already exists!"
            exit!
          end
      end

      def create_filter_file

        @ng_app_name = 'ngnrailsModules'
        @module_name = @ng_filter_name.underscore.camelize(:lower)
        template("app/assets/javascripts/ng/apps/filter_template.js.erb", "app/assets/javascripts/ng/modules/filters/#{@ng_filter_name.underscore.camelize}.js")

      end

    end
  end
end
