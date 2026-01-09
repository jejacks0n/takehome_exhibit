class ReadingsController < ActionController::API
  before_action :find_or_create_device

  def create


    render json: { success: true }, status: :created
  end

  private

  def find_or_create_device
    @device = Device.find_or_create_by(id: permitted_params[:id])
  end

  def permitted_params
    @permitted_params ||= begin
      params.require(:id)
      params.require(:readings)
      params.permit(:id, readings: [:timestamp, :count])
    end
  end
end