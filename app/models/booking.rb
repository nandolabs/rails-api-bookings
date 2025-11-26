class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :hotel

  enum :status, { pending: "pending", confirmed: "confirmed", cancelled: "cancelled" }

  validates :check_in, presence: true
  validates :check_out, presence: true
  validates :guests, presence: true, numericality: { greater_than: 0, only_integer: true }
  validate :check_out_after_check_in

  before_save :calculate_total_price

  private

  def check_out_after_check_in
    return if check_in.blank? || check_out.blank?

    if check_out <= check_in
      errors.add(:check_out, "must be after check in date")
    end
  end

  def calculate_total_price
    return unless check_in && check_out && hotel

    nights = (check_out - check_in).to_i
    self.total_price = nights * hotel.price_per_night
  end
end
