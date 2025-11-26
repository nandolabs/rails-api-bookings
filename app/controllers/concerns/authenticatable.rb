module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
  end

  private

  def authenticate_request
    header = request.headers["Authorization"]
    header = header.split(" ").last if header

    decoded = JsonWebToken.decode(header)

    if decoded
      @current_user = User.find_by(id: decoded[:user_id])
      render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
    else
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
