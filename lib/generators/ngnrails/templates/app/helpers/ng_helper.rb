module NgHelper

  # Include script tag with code to bootstrap Angular application
  # Must be used when more than 2 apps are on the same web page
  def ng_bootstrap_app(elem, app_name)
    content = "angular.bootstrap($('#{elem}'),['#{app_name}']);"
    ng_javascript_include_code(content)
  end

  def ng_javascript_include_code(content)
    javascript_tag "angular.element(document).ready(function () { #{content} });"
  end

  # Angular form builder
  def ng_form_for(object, options = {}, &block)

    options[:builder] = Ng::FormBuilder

    form_for(object, options, &block)
  end

end
