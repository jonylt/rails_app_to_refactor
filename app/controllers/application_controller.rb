# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  rescue_from ActionController::ParameterMissing, with: :show_parameter_missing_error

  protected

    def authenticate_user
      head :forbidden unless current_user
    end

    def current_user
      @current_user ||= authenticate_or_request_with_http_token do |token|
        User.find_by(token: token)
      end
    end

    def render_json(status, json = {})
      render status: status, json: json
    end

    def show_parameter_missing_error(exception)
      render_json(400, error: exception.message)
    end
end
