# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Seeding database..."

# Create sample hotels
hotels_data = [
  {
    name: "Grand Plaza Hotel",
    location: "New York, NY",
    description: "Luxury hotel in the heart of Manhattan with stunning city views, world-class amenities, and exceptional service.",
    price_per_night: 299.99
  },
  {
    name: "Beachside Resort & Spa",
    location: "Miami, FL",
    description: "Beautiful oceanfront resort featuring private beach access, full-service spa, and multiple dining options.",
    price_per_night: 199.99
  },
  {
    name: "Mountain View Lodge",
    location: "Denver, CO",
    description: "Cozy mountain retreat with breathtaking views, outdoor activities, and rustic charm.",
    price_per_night: 149.99
  },
  {
    name: "Downtown Business Hotel",
    location: "Chicago, IL",
    description: "Modern business hotel with state-of-the-art conference facilities and easy access to business district.",
    price_per_night: 179.99
  },
  {
    name: "Historic Inn & Suites",
    location: "Boston, MA",
    description: "Charming historic property with colonial architecture, period furnishings, and modern comforts.",
    price_per_night: 225.00
  }
]

hotels_data.each do |hotel_attrs|
  Hotel.find_or_create_by!(name: hotel_attrs[:name]) do |hotel|
    hotel.location = hotel_attrs[:location]
    hotel.description = hotel_attrs[:description]
    hotel.price_per_night = hotel_attrs[:price_per_night]
  end
end

puts "Created #{Hotel.count} hotels"

# Create sample users
sample_user = User.find_or_create_by!(email: 'demo@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.name = 'Demo User'
end

puts "Created demo user: #{sample_user.email}"

# Create sample bookings for demo user
if sample_user.bookings.empty?
  3.times do |i|
    hotel = Hotel.offset(i).first
    Booking.create!(
      user: sample_user,
      hotel: hotel,
      check_in: Date.today + (7 + i * 7).days,
      check_out: Date.today + (10 + i * 7).days,
      guests: rand(1..4),
      status: 'pending'
    )
  end
  puts "Created #{sample_user.bookings.count} sample bookings"
end

puts "Seeding completed!"
