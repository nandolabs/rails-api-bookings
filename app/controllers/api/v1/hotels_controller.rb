class Api::V1::HotelsController < ApplicationController
  def index
    hotels = Hotel.all
    render json: hotels.as_json(except: [ :created_at, :updated_at ])
  end

  def show
    hotel = Hotel.find_by(id: params[:id])

    if hotel
      render json: hotel.as_json(except: [ :created_at, :updated_at ])
    else
      render json: { error: "Hotel not found" }, status: :not_found
    end
  end
end
