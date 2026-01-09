class ReadingsController < ActionController::API
  before_action :find_or_initialize_device_data, only: :create

  rescue_from ActionController::ParameterMissing do
    render json: { error: "Invalid parameters" }, status: :unprocessable_content
  end

  def create
    Array(permitted_params[:readings]).each do |reading|
      timestamp = reading[:timestamp]
      next if @device_data[:timestamps].key?(timestamp) # ignore duplicates

      time = Time.parse(timestamp) rescue next # skip invalid timestamps
      count = reading[:count].to_i # ensure count values are integers

      @device_data[:timestamps][timestamp] = count
      @device_data[:cumulative_count] += count

      # Keep track of the latest timestamp.
      if @device_data[:latest_timestamp].nil? || time > @device_data[:latest_timestamp]
        @device_data[:latest_timestamp] = time
      end

      # We can write to the cache each time to try to reduce race conditions, but there
      # are downsides if this wasn't just in memory. Syncing the data to a persistent
      # datastore (even if just in memory) wouldn't be optimal as the data grows, so
      # we're left with improving the architecture/removing the limitations, or having a higher likelihood of race conditions.
      Rails.cache.write("device_#{permitted_params[:id]}", @device_data)
    end

    # We can also just write the cache data at the end of the loop, which is fine, but
    # does incur a higher risk of race conditions in high throughput / high concurrency
    # systems.
    # Rails.cache.write("device_#{permitted_params[:id]}", @device_data)

    render json: { message: "Readings created" }, status: :created
  end

  private

  def find_or_initialize_device_data
    @device_data = Rails.cache.fetch("device_#{permitted_params[:id]}") do
      { timestamps: {}, cumulative_count: 0, latest_timestamp: nil }
    end
  end

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