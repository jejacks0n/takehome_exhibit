require "spec_helper"

RSpec.describe DevicesController, type: :controller do
  let(:device_id) { "36d5658a-6908-479e-887e-a949ec199272" }
  let(:cache_key) { "device_#{device_id}" }
  let(:device_data) do
    {
      cumulative_count: 11,
      latest_timestamp: Time.parse("2021-09-29T16:09:15+01:00")
    }
  end

  before do
    device_data.each do |key, value|
      Rails.cache.write("#{cache_key}:#{key}", value)
    end
  end

  describe "GET #latest_timestamp" do
    context "when device data exists" do
      it "returns the latest timestamp" do
        get :latest_timestamp, params: {id: device_id}

        expect(response).to have_http_status(:success)

        json_response = JSON.parse(response.body)
        expect(json_response["latest_timestamp"]).to eq("2021-09-29T16:09:15+01:00")
      end
    end

    context "when device data does not exist" do
      it "responds with an error message (404)" do
        get :latest_timestamp, params: {id: "unknown-device"}

        expect(response).to have_http_status(:not_found)

        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Device not found")
      end
    end
  end

  describe "GET #cumulative_count" do
    context "when device data exists" do
      it "returns the cumulative count" do
        get :cumulative_count, params: {id: device_id}

        expect(response).to have_http_status(:success)

        json_response = JSON.parse(response.body)
        expect(json_response["cumulative_count"]).to eq(11)
      end
    end

    context "when device data does not exist" do
      it "responds with an error message (404)" do
        get :cumulative_count, params: {id: "unknown-device"}

        expect(response).to have_http_status(:not_found)

        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Device not found")
      end
    end
  end
end
