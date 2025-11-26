require 'rails_helper'

RSpec.describe "Api::V1::Hotels", type: :request do
  describe "GET /api/v1/hotels" do
    before do
      create_list(:hotel, 3)
    end

    it "returns all hotels" do
      get "/api/v1/hotels"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(3)
    end
  end

  describe "GET /api/v1/hotels/:id" do
    let(:hotel) { create(:hotel) }

    it "returns the hotel" do
      get "/api/v1/hotels/#{hotel.id}"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['id']).to eq(hotel.id)
      expect(json['name']).to eq(hotel.name)
    end

    it "returns not found for non-existent hotel" do
      get "/api/v1/hotels/99999"
      expect(response).to have_http_status(:not_found)
    end
  end
end
