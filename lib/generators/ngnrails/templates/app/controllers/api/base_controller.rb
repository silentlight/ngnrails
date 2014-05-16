class Api::BaseController < ApplicationController
  before_action :intercept_html_requests
  layout false

  private

  def intercept_html_requests
    redirect_to('/') if request.format == Mime::HTML
  end

  def render_with_protection(object, parameters = {})
    render parameters.merge(content_type: 'application/json', text: ")]}',\n" + object.to_json)
  end

end
