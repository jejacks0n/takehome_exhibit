require "spec_helper"

RSpec.describe ReadingsController, type: :controller do
  let(:device_id) { "36d5658a-6908-479e-887e-a949ec199272" }
  let(:cache_key) { "device_#{device_id}" }

  before do
    Rails.cache.clear
  end

  def cached_data(key)
    Rails.cache.read("#{cache_key}:#{key}")
  end

  describe "POST #create" do
    let(:valid_attributes) do
      {
        id: device_id,
        readings: [
          { timestamp: "2021-09-29T16:08:15+01:00", count: 5 },
          { timestamp: "2021-09-29T16:09:15+01:00", count: 6 }
        ]
      }
    end

    context "with valid params" do
      it "stores the readings in the cache" do
        post :create, params: valid_attributes

        expect(response).to have_http_status(:created)

        expect(cached_data(:cumulative_count)).to eq(11)
        expect(cached_data(:latest_timestamp)).to eq(Time.parse("2021-09-29T16:09:15+01:00"))
        expect(cached_data('2021-09-29T16:08:15+01:00')).to eq(5)
        expect(cached_data('2021-09-29T16:09:15+01:00')).to eq(6)
      end

      it "ignores duplicate readings" do
        post :create, params: valid_attributes
        post :create, params: valid_attributes

        expect(cached_data(:cumulative_count)).to eq(11) # should not double
      end

      it "updates existing device data" do
        post :create, params: valid_attributes.merge(readings: [{ timestamp: "2021-09-29T16:08:15+01:00", count: 5 }])

        expect(cached_data(:cumulative_count)).to eq(5)
        expect(cached_data(:latest_timestamp)).to eq(Time.parse("2021-09-29T16:08:15+01:00"))

        post :create, params: valid_attributes.merge(readings: [{ timestamp: "2021-09-29T16:09:15+01:00", count: 6 }])

        expect(cached_data(:cumulative_count)).to eq(11)
        expect(cached_data(:latest_timestamp)).to eq(Time.parse("2021-09-29T16:09:15+01:00"))
      end

      it "handles out of order readings" do
        valid_attributes[:readings].reverse!

        post :create, params: valid_attributes

        expect(cached_data(:cumulative_count)).to eq(11)
        expect(cached_data(:latest_timestamp)).to eq(Time.parse("2021-09-29T16:09:15+01:00"))
      end
    end

    context "with invalid params" do
      it "responds with an error message (422)" do
        post :create, params: { }

        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Invalid parameters")
      end
    end

    context "with bad data" do
      it "doesn't store anything if it's not an array" do
        post :create, params: { id: device_id, readings: "_bad_readings_" }

        expect(cached_data(:cumulative_count)).to eq(nil)
      end

      it "doesn't count readings with invalid timestamps" do
        valid_attributes[:readings].unshift({ timestamp: "_invalid_timestamp_", count: 10 })

        post :create, params: valid_attributes

        expect(cached_data(:cumulative_count)).to eq(11)
      end

      it "handles invalid count readings" do
        valid_attributes[:readings].unshift({ timestamp: "2021-09-29T16:10:15+01:00", count: 'm' })

        post :create, params: valid_attributes

        expect(cached_data(:cumulative_count)).to eq(11)
        expect(cached_data('2021-09-29T16:10:15+01:00')).to eq(0)
      end
    end
  end
end
