class Api::V1::BookingsController < ApplicationController
  include Authenticatable

  before_action :set_booking, only: [ :show, :update, :destroy ]
  before_action :authorize_booking, only: [ :show, :update, :destroy ]

  def index
    bookings = current_user.bookings.includes(:hotel)
    render json: bookings.as_json(include: { hotel: { except: [ :created_at, :updated_at ] } })
  end

  def create
    booking = current_user.bookings.new(booking_params)

    if booking.save
      render json: booking.as_json(include: { hotel: { except: [ :created_at, :updated_at ] } }), status: :created
    else
      render json: { errors: booking.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    render json: @booking.as_json(include: { hotel: { except: [ :created_at, :updated_at ] } })
  end

  def update
    if @booking.update(booking_params)
      render json: @booking.as_json(include: { hotel: { except: [ :created_at, :updated_at ] } })
    else
      render json: { errors: @booking.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @booking.destroy
    head :no_content
  end

  private

  def set_booking
    @booking = Booking.find_by(id: params[:id])
    render json: { error: "Booking not found" }, status: :not_found unless @booking
  end

  def authorize_booking
    return unless @booking

    unless @booking.user_id == current_user.id
      render json: { error: "Unauthorized access to booking" }, status: :forbidden
    end
  end

  def booking_params
    params.permit(:hotel_id, :check_in, :check_out, :guests, :status)
  end
end
