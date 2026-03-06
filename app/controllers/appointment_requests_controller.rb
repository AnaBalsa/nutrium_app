class AppointmentRequestsController < ApplicationController
  def create
    service = Service.find(appointment_request_params[:service_id])

    starts_at = Time.zone.parse("#{appointment_request_params[:date]} #{appointment_request_params[:time]}")

    AppointmentRequests::Create.new(
      service: service,
      guest_name: appointment_request_params[:guest_name],
      guest_email: appointment_request_params[:guest_email],
      starts_at: starts_at
    ).call

    redirect_to root_path, notice: "Request submitted! You'll receive an email when it's answered."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to root_path, alert: e.message
  rescue => e
    redirect_to root_path, alert: "Could not submit request: #{e.message}"
  end

  private

  def appointment_request_params
    params.require(:appointment_request).permit(:service_id, :guest_name, :guest_email, :date, :time)
  end
end
