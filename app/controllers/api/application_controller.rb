class Api::ApplicationController < ApplicationController
  before_action :authenticate_and_set_merchant

  rescue_from ActiveSupport::XMLConverter::DisallowedType do |exception|
    render xml: {errors: ["invalid XML types"]}, status: 403
  end

  def rich_params
    if request.format.xml?
      request.body.rewind
      data = Hash.from_xml(request.body.read)
      data = data.dig("hash") || data.dig("objects")
      return ActionController::Parameters.new(data) if request.format.xml?
    end

    params
  end
end
