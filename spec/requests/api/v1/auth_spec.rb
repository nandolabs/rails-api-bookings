require 'rails_helper'

RSpec.describe "Api::V1::Auths", type: :request do
  describe "POST /api/v1/signup" do
    let(:valid_attributes) do
      {
        email: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123',
        name: 'Test User'
      }
    end

    context 'with valid parameters' do
      it 'creates a new user and returns a token' do
        post '/api/v1/signup', params: valid_attributes

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['token']).to be_present
        expect(json['user']['email']).to eq('test@example.com')
        expect(json['user']['name']).to eq('Test User')
        expect(json['user']).not_to have_key('password_digest')
      end
    end

    context 'with invalid email' do
      it 'returns validation errors' do
        post '/api/v1/signup', params: valid_attributes.merge(email: 'invalid')

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to be_present
      end
    end

    context 'with duplicate email' do
      it 'returns validation errors' do
        create(:user, email: 'test@example.com')
        post '/api/v1/signup', params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include(/Email has already been taken/)
      end
    end

    context 'with short password' do
      it 'returns validation errors' do
        post '/api/v1/signup', params: valid_attributes.merge(password: '12345', password_confirmation: '12345')

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to be_present
      end
    end
  end

  describe "POST /api/v1/login" do
    let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    context 'with valid credentials' do
      it 'returns a token' do
        post '/api/v1/login', params: { email: 'test@example.com', password: 'password123' }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['token']).to be_present
        expect(json['user']['email']).to eq('test@example.com')
        expect(json['user']).not_to have_key('password_digest')
      end
    end

    context 'with invalid email' do
      it 'returns unauthorized error' do
        post '/api/v1/login', params: { email: 'wrong@example.com', password: 'password123' }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Invalid email or password')
      end
    end

    context 'with invalid password' do
      it 'returns unauthorized error' do
        post '/api/v1/login', params: { email: 'test@example.com', password: 'wrongpassword' }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Invalid email or password')
      end
    end
  end
end
