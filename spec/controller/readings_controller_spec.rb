require "spec_helper"

RSpec.describe ReadingsController, type: :controller do
  describe "POST #create" do
    it "tests" do
      post :create

      expect(response).to have_http_status(:created)
    end
  end
end
