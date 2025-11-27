require 'swagger_helper'

RSpec.describe 'Authentication API', type: :request do
  path '/api/v1/signup' do
    post 'Register a new user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      description 'Creates a new user account and returns a JWT token'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'user@example.com', description: 'User email address' },
          password: { type: :string, example: 'password123', description: 'User password (minimum 6 characters)' },
          password_confirmation: { type: :string, example: 'password123', description: 'Password confirmation' },
          name: { type: :string, example: 'John Doe', description: 'User full name' }
        },
        required: [ 'email', 'password', 'password_confirmation', 'name' ]
      }

      response '201', 'User created successfully' do
        let(:user) { { email: 'newuser@example.com', password: 'password123', password_confirmation: 'password123', name: 'New User' } }

        schema type: :object,
          properties: {
            token: { type: :string, description: 'JWT authentication token', example: 'eyJhbGciOiJIUzI1NiJ9...' },
            user: {
              type: :object,
              properties: {
                id: { type: :integer, example: 1 },
                email: { type: :string, example: 'user@example.com' },
                name: { type: :string, example: 'John Doe' },
                created_at: { type: :string, format: 'date-time' },
                updated_at: { type: :string, format: 'date-time' }
              }
            }
          }

        run_test!
      end

      response '422', 'Invalid request' do
        let(:user) { { email: 'invalid', password: 'short' } }

        schema type: :object,
          properties: {
            errors: {
              type: :array,
              items: { type: :string },
              example: [ 'Email is invalid', 'Password is too short' ]
            }
          }

        run_test!
      end
    end
  end

  path '/api/v1/login' do
    post 'Login and get JWT token' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      description 'Authenticates user credentials and returns a JWT token'

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'user@example.com', description: 'User email address' },
          password: { type: :string, example: 'password123', description: 'User password' }
        },
        required: [ 'email', 'password' ]
      }

      response '200', 'Login successful' do
        let!(:existing_user) { User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123', name: 'Test User') }
        let(:credentials) { { email: 'test@example.com', password: 'password123' } }

        schema type: :object,
          properties: {
            token: { type: :string, description: 'JWT authentication token', example: 'eyJhbGciOiJIUzI1NiJ9...' },
            user: {
              type: :object,
              properties: {
                id: { type: :integer, example: 1 },
                email: { type: :string, example: 'user@example.com' },
                name: { type: :string, example: 'John Doe' },
                created_at: { type: :string, format: 'date-time' },
                updated_at: { type: :string, format: 'date-time' }
              }
            }
          }

        run_test!
      end

      response '401', 'Invalid credentials' do
        let(:credentials) { { email: 'test@example.com', password: 'wrongpassword' } }

        schema type: :object,
          properties: {
            error: { type: :string, example: 'Invalid email or password' }
          }

        run_test!
      end
    end
  end
end
