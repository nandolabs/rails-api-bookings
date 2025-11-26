# Rails API Bookings

A professional Rails 7 API-only application that exposes a realistic hotel booking system with JWT authentication. This project demonstrates idiomatic Rails 7 code, RESTful API design, comprehensive testing with RSpec, and secure authentication patterns.

## Features

- **JWT Authentication**: Secure user signup and login with bcrypt password hashing
- **Booking Management**: Full CRUD operations on bookings with ownership authorization
- **Hotel Catalog**: Read-only hotel endpoints for browsing available properties
- **Smart Validation**: Date validation (check-out must be after check-in), automatic price calculation
- **Authorization**: Users can only access and modify their own bookings
- **Comprehensive Testing**: RSpec tests with FactoryBot fixtures and Shoulda matchers
- **RESTful Design**: API versioning (v1 namespace) following REST conventions

## Tech Stack

- **Ruby**: 3.2.3
- **Rails**: 7.2.2.1 (API-only mode)
- **Database**: PostgreSQL
- **Authentication**: JWT (JSON Web Tokens) with bcrypt
- **Testing**: RSpec, FactoryBot, Shoulda Matchers, Faker
- **Docker**: Dockerized setup included

## Prerequisites

- Ruby 3.2 or higher
- Rails 7.1 or higher
- PostgreSQL 12 or higher
- Bundler 2.0+

## Installation

1. **Clone the repository**:
```bash
git clone https://github.com/nandolabs/rails-api-bookings.git
cd rails-api-bookings
```

2. **Install dependencies**:
```bash
bundle install
```

3. **Configure database**:
Edit `config/database.yml` if needed with your PostgreSQL credentials.

4. **Setup database**:
```bash
rails db:create
rails db:migrate
rails db:seed
```

The seed file creates:
- 5 sample hotels (Grand Plaza Hotel, Beachside Resort, etc.)
- 1 demo user (email: `demo@example.com`, password: `password123`)
- 3 sample bookings for the demo user

## Running the Application

Start the Rails server:
```bash
rails server
```

The API will be available at `http://localhost:3000`

## API Documentation

### Base URL
```
http://localhost:3000/api/v1
```

### Authentication Endpoints

#### Sign Up
Create a new user account and receive a JWT token.

**Endpoint**: `POST /api/v1/signup`

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "name": "John Doe"
}
```

**Response** (201 Created):
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

**cURL Example**:
```bash
curl -X POST http://localhost:3000/api/v1/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "name": "John Doe"
  }'
```

#### Log In
Authenticate with existing credentials and receive a JWT token.

**Endpoint**: `POST /api/v1/login`

**Request Body**:
```json
{
  "email": "demo@example.com",
  "password": "password123"
}
```

**Response** (200 OK):
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "email": "demo@example.com",
    "name": "Demo User"
  }
}
```

**cURL Example**:
```bash
curl -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "demo@example.com",
    "password": "password123"
  }'
```

### Hotel Endpoints (Public - No Authentication Required)

#### List All Hotels
Get a list of all available hotels.

**Endpoint**: `GET /api/v1/hotels`

**Response** (200 OK):
```json
[
  {
    "id": 1,
    "name": "Grand Plaza Hotel",
    "location": "New York, NY",
    "description": "Luxury hotel in the heart of Manhattan...",
    "price_per_night": "299.99"
  }
]
```

**cURL Example**:
```bash
curl http://localhost:3000/api/v1/hotels
```

#### Get Hotel Details
Get detailed information about a specific hotel.

**Endpoint**: `GET /api/v1/hotels/:id`

**Response** (200 OK):
```json
{
  "id": 1,
  "name": "Grand Plaza Hotel",
  "location": "New York, NY",
  "description": "Luxury hotel in the heart of Manhattan...",
  "price_per_night": "299.99"
}
```

**cURL Example**:
```bash
curl http://localhost:3000/api/v1/hotels/1
```

### Booking Endpoints (Protected - Requires Authentication)

All booking endpoints require a valid JWT token in the Authorization header:
```
Authorization: Bearer YOUR_JWT_TOKEN
```

#### List User's Bookings
Get all bookings for the authenticated user.

**Endpoint**: `GET /api/v1/bookings`

**Headers**:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**Response** (200 OK):
```json
[
  {
    "id": 1,
    "user_id": 1,
    "hotel_id": 1,
    "check_in": "2025-12-02",
    "check_out": "2025-12-05",
    "guests": 2,
    "total_price": "899.97",
    "status": "pending",
    "hotel": {
      "id": 1,
      "name": "Grand Plaza Hotel",
      "location": "New York, NY",
      "description": "Luxury hotel...",
      "price_per_night": "299.99"
    }
  }
]
```

**cURL Example**:
```bash
curl http://localhost:3000/api/v1/bookings \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

#### Create a Booking
Create a new hotel booking for the authenticated user.

**Endpoint**: `POST /api/v1/bookings`

**Headers**:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**Request Body**:
```json
{
  "hotel_id": 1,
  "check_in": "2025-12-15",
  "check_out": "2025-12-18",
  "guests": 2
}
```

**Response** (201 Created):
```json
{
  "id": 4,
  "user_id": 1,
  "hotel_id": 1,
  "check_in": "2025-12-15",
  "check_out": "2025-12-18",
  "guests": 2,
  "total_price": "899.97",
  "status": "pending",
  "hotel": {
    "id": 1,
    "name": "Grand Plaza Hotel"
  }
}
```

**Validation Rules**:
- `check_out` must be after `check_in`
- `guests` must be greater than 0
- `hotel_id` must reference an existing hotel
- `total_price` is calculated automatically (nights × hotel price_per_night)

**cURL Example**:
```bash
curl -X POST http://localhost:3000/api/v1/bookings \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "hotel_id": 1,
    "check_in": "2025-12-15",
    "check_out": "2025-12-18",
    "guests": 2
  }'
```

#### Get Booking Details
Get details of a specific booking (must be owned by authenticated user).

**Endpoint**: `GET /api/v1/bookings/:id`

**cURL Example**:
```bash
curl http://localhost:3000/api/v1/bookings/1 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

#### Update a Booking
Update an existing booking (must be owned by authenticated user).

**Endpoint**: `PATCH /api/v1/bookings/:id`

**Request Body** (partial update):
```json
{
  "guests": 4,
  "status": "confirmed"
}
```

**cURL Example**:
```bash
curl -X PATCH http://localhost:3000/api/v1/bookings/1 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"guests": 4, "status": "confirmed"}'
```

#### Delete a Booking
Delete a booking (must be owned by authenticated user).

**Endpoint**: `DELETE /api/v1/bookings/:id`

**Response** (204 No Content)

**cURL Example**:
```bash
curl -X DELETE http://localhost:3000/api/v1/bookings/1 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Status Codes

- `200 OK`: Successful GET/PATCH/PUT request
- `201 Created`: Successful POST request (resource created)
- `204 No Content`: Successful DELETE request
- `401 Unauthorized`: Missing or invalid JWT token
- `403 Forbidden`: User doesn't have permission for this resource
- `404 Not Found`: Resource not found
- `422 Unprocessable Entity`: Validation errors

## Testing

Run the full test suite:
```bash
bundle exec rspec
```

**Test Results**: 47 examples, 0 failures

### Test Coverage

The project includes comprehensive test coverage:
- **Model Tests**: Validations, associations, callbacks, custom validation logic
- **Request Tests**: Authentication (signup, login), CRUD operations with authorization
- **Test Tools**: RSpec, FactoryBot (realistic fixtures), Shoulda Matchers, Faker

## Project Structure

```
app/
├── controllers/
│   ├── api/v1/
│   │   ├── auth_controller.rb       # Signup & Login
│   │   ├── bookings_controller.rb   # Bookings CRUD
│   │   └── hotels_controller.rb     # Hotels index & show
│   └── concerns/
│       ├── authenticatable.rb       # JWT authentication helpers
│       └── json_web_token.rb        # JWT encoding/decoding
├── models/
│   ├── user.rb                      # User model with bcrypt
│   ├── hotel.rb                     # Hotel model
│   └── booking.rb                   # Booking with validations & callbacks
spec/
├── factories/                       # FactoryBot fixtures
├── models/                          # Model tests
└── requests/                        # Request specs (API tests)
```

## Key Design Decisions

1. **API-only Mode**: No views, assets, or frontend. Pure JSON API.
2. **Namespacing**: `/api/v1` namespace for future versioning flexibility.
3. **JWT Authentication**: Stateless authentication suitable for modern APIs.
4. **Authorization**: Users can only access their own bookings (ownership verification).
5. **Automatic Pricing**: Total price calculated from dates and hotel price.
6. **Idiomatic Rails**: Uses Rails conventions (concerns, before_action, strong params).
7. **Comprehensive Testing**: 47 test examples covering happy paths and edge cases.

## Security Features

- Password hashing with bcrypt
- JWT token expiration (24 hours)
- Strong parameter filtering
- Email validation and uniqueness
- Authorization checks on protected resources

## License

MIT License - Portfolio project demonstrating Rails API skills.
