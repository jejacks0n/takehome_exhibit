class ReadingsController < ActionController::API
  rescue_from ActionController::ParameterMissing do
    render json: {error: "Invalid parameters"}, status: :unprocessable_content
  end

  def create
    cache_key = "device_#{permitted_params[:id]}"
    Array(permitted_params[:readings]).each do |reading|
      timestamp = reading[:timestamp]
      count = reading[:count].to_i # ensure count values are integers
      reading_time = begin
        Time.parse(timestamp)
      rescue
        next # skip invalid timestamps
      end

      Rails.cache.fetch("#{cache_key}:#{timestamp}") do
        Rails.cache.increment("#{cache_key}:cumulative_count", count)

        # Keep track of the latest timestamp.
        current_latest = Rails.cache.read("#{cache_key}:latest_timestamp")
        if current_latest.nil? || current_latest < reading_time
          Rails.cache.write("#{cache_key}:latest_timestamp", reading_time)
        end

        count
      end
    end

    render json: {message: "Readings created"}, status: :created
  end

  private

  def permitted_params
    # We don't explicitly need permitted params without ActiveRecord, but we can use them
    # for some semblance of schema enforcement. There's better ways to do this with, like
    # with ActiveRecord for example, but I don't think that's what the exercise is for.
    @permitted_params ||= begin
      params.require(:id)
      params.require(:readings)
      params.permit(:id, readings: [:timestamp, :count])
    end
  end
end
