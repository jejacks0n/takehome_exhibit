class DevicesController < ActionController::API
  DeviceDataNotFoundError = Class.new(StandardError)

  before_action :find_device_data

  rescue_from DeviceDataNotFoundError do
    render json: {error: "Device not found"}, status: :not_found
  end

  def latest_timestamp
    render json: {latest_timestamp: @device_data.iso8601}
  end

  def cumulative_count
    render json: {cumulative_count: @device_data}
  end

  private

  def find_device_data
    @device_data = Rails.cache.read("device_#{params[:id]}:#{params[:action]}")
    raise DeviceDataNotFoundError if @device_data.nil?
  end
end
