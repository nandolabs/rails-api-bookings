require 'rails_helper'

RSpec.describe "Api::V1::Bookings", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:hotel) { create(:hotel) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  describe "GET /api/v1/bookings" do
    context 'when authenticated' do
      before do
        create_list(:booking, 3, user: user)
        create_list(:booking, 2, user: other_user)
      end

      it 'returns current user bookings only' do
        get '/api/v1/bookings', headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.length).to eq(3)
        json.each do |booking|
          expect(booking['user_id']).to eq(user.id)
          expect(booking['hotel']).to be_present
        end
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized error' do
        get '/api/v1/bookings'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /api/v1/bookings" do
    let(:valid_attributes) do
      {
        hotel_id: hotel.id,
        check_in: Date.today + 7.days,
        check_out: Date.today + 10.days,
        guests: 2
      }
    end

    context 'with valid parameters' do
      it 'creates a new booking' do
        expect {
          post '/api/v1/bookings', params: valid_attributes, headers: headers
        }.to change(Booking, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['user_id']).to eq(user.id)
        expect(json['hotel_id']).to eq(hotel.id)
        expect(json['guests']).to eq(2)
        expect(json['total_price']).to be_present
        expect(json['hotel']).to be_present
      end
    end

    context 'with invalid dates (check_out before check_in)' do
      it 'returns validation errors' do
        post '/api/v1/bookings', params: valid_attributes.merge(
          check_in: Date.today + 10.days,
          check_out: Date.today + 7.days
        ), headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include(/must be after check in date/)
      end
    end

    context 'with missing required fields' do
      it 'returns validation errors' do
        post '/api/v1/bookings', params: { hotel_id: hotel.id }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to be_present
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized error' do
        post '/api/v1/bookings', params: valid_attributes

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/v1/bookings/:id" do
    let(:booking) { create(:booking, user: user) }
    let(:other_booking) { create(:booking, user: other_user) }

    context 'when booking belongs to current user' do
      it 'returns the booking' do
        get "/api/v1/bookings/#{booking.id}", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['id']).to eq(booking.id)
        expect(json['hotel']).to be_present
      end
    end

    context 'when booking belongs to another user' do
      it 'returns forbidden error' do
        get "/api/v1/bookings/#{other_booking.id}", headers: headers

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when booking does not exist' do
      it 'returns not found error' do
        get "/api/v1/bookings/99999", headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "PATCH /api/v1/bookings/:id" do
    let(:booking) { create(:booking, user: user, guests: 2) }
    let(:other_booking) { create(:booking, user: other_user) }

    context 'when booking belongs to current user' do
      it 'updates the booking' do
        patch "/api/v1/bookings/#{booking.id}", params: { guests: 4 }, headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['guests']).to eq(4)
        expect(booking.reload.guests).to eq(4)
      end
    end

    context 'with invalid data' do
      it 'returns validation errors' do
        patch "/api/v1/bookings/#{booking.id}", params: {
          check_in: Date.today + 10.days,
          check_out: Date.today + 7.days
        }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when booking belongs to another user' do
      it 'returns forbidden error' do
        patch "/api/v1/bookings/#{other_booking.id}", params: { guests: 4 }, headers: headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "DELETE /api/v1/bookings/:id" do
    let!(:booking) { create(:booking, user: user) }
    let!(:other_booking) { create(:booking, user: other_user) }

    context 'when booking belongs to current user' do
      it 'deletes the booking' do
        expect {
          delete "/api/v1/bookings/#{booking.id}", headers: headers
        }.to change(Booking, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when booking belongs to another user' do
      it 'returns forbidden error and does not delete' do
        expect {
          delete "/api/v1/bookings/#{other_booking.id}", headers: headers
        }.not_to change(Booking, :count)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
