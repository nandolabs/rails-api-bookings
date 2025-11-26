require 'rails_helper'

RSpec.describe Hotel, type: :model do
  describe 'associations' do
    it { should have_many(:bookings).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:location) }
    it { should validate_presence_of(:price_per_night) }
    it { should validate_numericality_of(:price_per_night).is_greater_than(0) }
  end
end
