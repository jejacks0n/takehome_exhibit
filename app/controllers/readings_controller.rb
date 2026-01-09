class ReadingsController < ActionController::API
  def create
    render json: { success: true }, status: :created
  end
end