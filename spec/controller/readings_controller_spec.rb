require "spec_helper"

RSpec.describe ReadingsController, type: :controller do
  let(:device_id) { "36d5658a-6908-479e-887e-a949ec199272" }

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

    it "creates a device record" do
      post :create, params: valid_attributes
    end
  end
end
