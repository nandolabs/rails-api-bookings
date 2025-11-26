class Hotel < ApplicationRecord
  has_many :bookings, dependent: :destroy

  validates :name, presence: true
  validates :location, presence: true
  validates :price_per_night, presence: true, numericality: { greater_than: 0 }
end
