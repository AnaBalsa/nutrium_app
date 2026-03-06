module Api
  class AppointmentRequestsController < ApplicationController
    protect_from_forgery with: :null_session

    def index
      nutritionist = Nutritionist.find(params[:nutritionist_id])

      scope = AppointmentRequest
        .includes(:service)
        .where(nutritionist_id: nutritionist.id)

      scope = scope.where(status: params[:status]) if params[:status].present?

      requests = scope.order(starts_at: :asc)

      render json: requests.map { |appointment_request| serialize_request(appointment_request) }
    end

    def decide
      appointment_request = AppointmentRequest.find(params[:id])
      decision = params[:decision].to_s

      decided = AppointmentRequests::Decide.new(
        appointment_request: appointment_request,
        decision: decision
      ).call

      render json: { id: decided.id, status: decided.status }
    rescue ArgumentError, ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    def serialize_request(appointment_request)
      {
        id: appointment_request.id,
        status: appointment_request.status,
        guest_name: appointment_request.guest_name,
        guest_email: appointment_request.guest_email,
        starts_at: appointment_request.starts_at,
        ends_at: appointment_request.ends_at,
        service: {
          id: appointment_request.service.id,
          name: appointment_request.service.name,
          duration_minutes: appointment_request.service.duration_minutes,
          price: appointment_request.service.price,
          currency: appointment_request.service.currency,
          location_name: appointment_request.service.location_name
        }
      }
    end
  end
end
