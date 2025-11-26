require 'rails_helper'

RSpec.describe Booking, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:hotel) }
  end

  describe 'validations' do
    it { should validate_presence_of(:check_in) }
    it { should validate_presence_of(:check_out) }
    it { should validate_presence_of(:guests) }
    it { should validate_numericality_of(:guests).only_integer.is_greater_than(0) }

    it 'validates check_out is after check_in' do
      booking = build(:booking, check_in: Date.today, check_out: Date.today - 1.day)
      expect(booking).not_to be_valid
      expect(booking.errors[:check_out]).to include('must be after check in date')
    end

    it 'is valid when check_out is after check_in' do
      booking = build(:booking, check_in: Date.today, check_out: Date.today + 1.day)
      expect(booking).to be_valid
    end
  end

  describe 'callbacks' do
    it 'calculates total_price before save' do
      hotel = create(:hotel, price_per_night: 100)
      booking = build(:booking, hotel: hotel, check_in: Date.today, check_out: Date.today + 3.days)
      booking.save
      expect(booking.total_price).to eq(300)
    end
  end

  describe 'enums' do
    it 'defines status enum values' do
      expect(Booking.statuses.keys).to contain_exactly('pending', 'confirmed', 'cancelled')
    end
  end
end
