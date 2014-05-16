class Ng::FormBuilder < Foundation::FormBuilder

  def initialize(object_name, object, template, options)

    # Add html hash if not exists
    if options[:html].nil?
      options[:html] = {}
    end

    # Remove url in order for angular form to work
    options[:url] = ""

    # Add ng-submit directive
    if object.new_record?
      if options[:html]['ng-submit'].nil?
        options[:html]['ng-submit'] = 'save()';
      end
    else
      if options[:html]['ng-submit'].nil?
        options[:html]['ng-submit'] = 'edit()';
      end
    end

    # Add name attribute
    if options[:html]['name'].nil?
      options[:html]['name'] = get_ng_form_name(object_name)
    end

    @ng_form_name = options[:html]['name']

    super(object_name, object, template, options)
  end

  %w[text_field text_area password_field].each do |method_name|
    define_method(method_name) do |name, *args|

      options = args.extract_options!

      options['name']     = options['name'].nil? ? get_input_name(name) : get_input_name(options['name'])
      options['ng-model'] = get_ng_model(name) if options['ng-model'].nil?
      options['ng-class'] = 'error.name ? "error" : ""' if options['ng-class'].nil?
      options.reverse_merge!(get_validation_options(name))

      args << options

      super(name, get_error_box(name), *args)

    end

  end

  def collection_select(name, collection, value_method, text_method, options = {}, html_options = {})

    # Add HTML options
    html_options['name']     = options['name'].nil? ? get_input_name(name) : get_input_name(options['name'])
    html_options['ng-model'] = get_ng_model(name) if options['ng-model'].nil?
    html_options['ng-class'] = 'error.name ? "error" : ""' if options['ng-class'].nil?
    html_options.reverse_merge!(get_validation_options(name))

    super(name, collection, value_method, text_method, options, html_options, get_error_box(name))

  end

  def select(name, option_tags, options={}, html_options={})

    # Add HTML options
    html_options['name']     = options['name'].nil? ? get_input_name(name) : get_input_name(options['name'])
    html_options['ng-model'] = get_ng_model(name) if options['ng-model'].nil?
    html_options['ng-class'] = 'error.name ? "error" : ""' if options['ng-class'].nil?
    html_options.reverse_merge!(get_validation_options(name))

    super(name, option_tags, options, html_options, get_error_box(name))

  end

  def submit(*args)

    options = args.extract_options!

    # Disable is set to TRUE as a default
    if options[:disable].nil?
      options[:disable] = true
    end

    if options[:disable]
      options['ng-disabled'] = options['ng-disabled'].nil?  ? "!#{@ng_form_name}.$valid" : options['ng-disabled']
    end

    args << options

    super(*args)

  end

  private

  def required?(name)
    object.class.validators_on(name).any? { |v| v.kind_of? ActiveModel::Validations::PresenceValidator }
  end

  def get_ng_model(name)
    @object_name.to_s.downcase + "." + name.to_s.downcase
  end

  def get_ng_form_name(object_name)
    'new' + object_name.to_s.capitalize + 'Form'
  end

  def get_input_name(name)
    name.to_s + "Input"
  end

  def get_validation_options(name)

    options = {}

    object.class.validators_on(name).each do |validator|

      if validator.kind_of? ActiveModel::Validations::PresenceValidator

        options['required'] = 'required'

      elsif validator.kind_of? ActiveModel::Validations::FormatValidator

        options['ng-pattern'] = "/#{validator.options[:with].source}/"

      elsif validator.kind_of? ActiveModel::Validations::LengthValidator

        if validator.options[:minimum]
          options['ng-minlength'] = validator.options[:minimum]
        end

        if validator.options[:maximum]
          options['ng-maxlength'] = validator.options[:maximum]
        end

        if validator.options[:is]
          options['ng-minlength'] = validator.options[:is]
          options['ng-maxlength'] = validator.options[:is]
        end

      end

    end

    options
  end

  def get_error_box(name)
    new_obj = object.class.new()

    field_path = @ng_form_name + "." + get_input_name(name)

    html = ""

    # Get all validators and create error boxes for each of them
    object.class.validators_on(name).each do |validator|

      if validator.kind_of? ActiveModel::Validations::PresenceValidator
        new_obj.validates_presence_of(name)

        if validator.options[:message].nil?
          message = new_obj.errors.full_messages.first
        else
          message = validator.options[:message]
        end

        # Foundation specific error box
        html += content_tag :small, class: 'error', 'ng-show' => "#{field_path}.$error.required && #{field_path}.$dirty" do
        message
      end

      elsif validator.kind_of? ActiveModel::Validations::FormatValidator

      # With Angular you can only use ^ and $
      # With Rails you must set multiline to true
      new_obj.validates_format_of(name, { with: validator.options[:with], multiline: true })

      if validator.options[:message].nil?
        message = new_obj.errors.full_messages.first
      else
        message = validator.options[:message]
      end

      # Foundation specific error box
      html += content_tag :small, class: 'error', 'ng-show' => "#{field_path}.$error.pattern && #{field_path}.$dirty" do
      message
    end

    elsif validator.kind_of? ActiveModel::Validations::LengthValidator

    # Using :minimum
    if validator.options[:minimum]

      new_obj.validates_length_of(name, minimum: validator.options[:minimum])

      if validator.options[:message].nil?
        message = new_obj.errors.full_messages.first
      else
        message = validator.options[:message]
      end

      # Foundation specific error box
      html += content_tag :small, class: 'error', 'ng-show' => "#{field_path}.$error.minlength && #{field_path}.$dirty" do
      message
    end

  end

  # Using :maximum
  if validator.options[:maximum]

    # Mock length to be too long
    long_obj = object.class.new({name: "a" * (validator.options[:maximum] + 1)})
    long_obj.validates_length_of(name, maximum: validator.options[:maximum])

    if validator.options[:message].nil?
      message = long_obj.errors.full_messages.first
    else
      message = validator.options[:message]
    end

    # Foundation specific error box
    html += content_tag :small, class: 'error', 'ng-show' => "#{field_path}.$error.maxlength && #{field_path}.$dirty" do
    message
  end

end

# Using :is
if validator.options[:is]

  new_obj.validates_length_of(name, is: validator.options[:is])

  if validator.options[:message].nil?
    message = new_obj.errors.full_messages.first
  else
    message = validator.options[:message]
  end

  # Foundation specific error box
  html += content_tag :small, class: 'error', 'ng-show' => "(#{field_path}.$error.minlength || #{field_path}.$error.maxlength) && #{field_path}.$dirty" do
  message
end

end

end

new_obj.errors.clear

end

html.html_safe
end
end
