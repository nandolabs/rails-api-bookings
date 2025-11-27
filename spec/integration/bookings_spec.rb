require 'swagger_helper'

RSpec.describe 'Bookings API', type: :request do
  path '/api/v1/bookings' do
    get 'List all bookings for authenticated user' do
      tags 'Bookings'
      produces 'application/json'
      security [ bearerAuth: [] ]
      description 'Returns all bookings belonging to the authenticated user'

      response '200', 'Bookings retrieved successfully' do
        let(:user) { User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123', name: 'Test User') }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: user.id)}" }

        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              user_id: { type: :integer, example: 1 },
              title: { type: :string, example: 'Conference Room Booking' },
              description: { type: :string, example: 'Team meeting' },
              start_time: { type: :string, format: 'date-time', example: '2024-01-15T10:00:00Z' },
              end_time: { type: :string, format: 'date-time', example: '2024-01-15T11:00:00Z' },
              status: { type: :string, enum: [ 'pending', 'confirmed', 'cancelled' ], example: 'confirmed' },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            }
          }

        run_test!
      end

      response '401', 'Unauthorized - Missing or invalid token' do
        let(:Authorization) { 'Bearer invalid_token' }

        schema type: :object,
          properties: {
            error: { type: :string, example: 'Unauthorized' }
          }

        run_test!
      end
    end

    post 'Create a new booking' do
      tags 'Bookings'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]
      description 'Creates a new booking for the authenticated user'

      parameter name: :booking, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string, example: 'Conference Room Booking', description: 'Booking title' },
          description: { type: :string, example: 'Team meeting', description: 'Booking description (optional)' },
          start_time: { type: :string, format: 'date-time', example: '2024-01-15T10:00:00Z', description: 'Booking start time' },
          end_time: { type: :string, format: 'date-time', example: '2024-01-15T11:00:00Z', description: 'Booking end time' },
          status: { type: :string, enum: [ 'pending', 'confirmed', 'cancelled' ], example: 'pending', description: 'Booking status' }
        },
        required: [ 'title', 'start_time', 'end_time' ]
      }

      response '201', 'Booking created successfully' do
        let(:user) { User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123', name: 'Test User') }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: user.id)}" }
        let(:booking) { { title: 'New Booking', start_time: 1.day.from_now, end_time: 1.day.from_now + 1.hour } }

        schema type: :object,
          properties: {
            id: { type: :integer, example: 1 },
            user_id: { type: :integer, example: 1 },
            title: { type: :string, example: 'Conference Room Booking' },
            description: { type: :string, example: 'Team meeting' },
            start_time: { type: :string, format: 'date-time' },
            end_time: { type: :string, format: 'date-time' },
            status: { type: :string, example: 'pending' },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          }

        run_test!
      end

      response '422', 'Invalid request' do
        let(:user) { User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123', name: 'Test User') }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: user.id)}" }
        let(:booking) { { title: '' } }

        schema type: :object,
          properties: {
            errors: {
              type: :array,
              items: { type: :string },
              example: [ "Title can't be blank", "Start time can't be blank" ]
            }
          }

        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:booking) { { title: 'Test', start_time: Time.now, end_time: 1.hour.from_now } }

        run_test!
      end
    end
  end

  path '/api/v1/bookings/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Booking ID'

    get 'Get booking details' do
      tags 'Bookings'
      produces 'application/json'
      security [ bearerAuth: [] ]
      description 'Returns details of a specific booking (owner only)'

      response '200', 'Booking found' do
        let(:user) { User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123', name: 'Test User') }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: user.id)}" }
        let(:id) { Booking.create!(user: user, title: 'Test Booking', start_time: 1.day.from_now, end_time: 1.day.from_now + 1.hour).id }

        schema type: :object,
          properties: {
            id: { type: :integer },
            user_id: { type: :integer },
            title: { type: :string },
            description: { type: :string },
            start_time: { type: :string, format: 'date-time' },
            end_time: { type: :string, format: 'date-time' },
            status: { type: :string },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          }

        run_test!
      end

      response '404', 'Booking not found' do
        let(:user) { User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123', name: 'Test User') }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: user.id)}" }
        let(:id) { 999999 }

        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { 1 }

        run_test!
      end
    end

    patch 'Update booking' do
      tags 'Bookings'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]
      description 'Updates a booking (owner only)'

      parameter name: :booking, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string, example: 'Updated Booking Title' },
          description: { type: :string, example: 'Updated description' },
          start_time: { type: :string, format: 'date-time' },
          end_time: { type: :string, format: 'date-time' },
          status: { type: :string, enum: [ 'pending', 'confirmed', 'cancelled' ] }
        }
      }

      response '200', 'Booking updated successfully' do
        let(:user) { User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123', name: 'Test User') }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: user.id)}" }
        let(:id) { Booking.create!(user: user, title: 'Original', start_time: 1.day.from_now, end_time: 1.day.from_now + 1.hour).id }
        let(:booking) { { title: 'Updated Title' } }

        run_test!
      end

      response '404', 'Booking not found' do
        let(:user) { User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123', name: 'Test User') }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: user.id)}" }
        let(:id) { 999999 }
        let(:booking) { { title: 'Updated' } }

        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { 1 }
        let(:booking) { { title: 'Updated' } }

        run_test!
      end
    end

    delete 'Delete booking' do
      tags 'Bookings'
      produces 'application/json'
      security [ bearerAuth: [] ]
      description 'Deletes a booking (owner only)'

      response '204', 'Booking deleted successfully' do
        let(:user) { User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123', name: 'Test User') }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: user.id)}" }
        let(:id) { Booking.create!(user: user, title: 'To Delete', start_time: 1.day.from_now, end_time: 1.day.from_now + 1.hour).id }

        run_test!
      end

      response '404', 'Booking not found' do
        let(:user) { User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123', name: 'Test User') }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: user.id)}" }
        let(:id) { 999999 }

        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { 1 }

        run_test!
      end
    end
  end
end
