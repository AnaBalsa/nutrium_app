class AppointmentRequestMailer < ApplicationMailer
  def send_notification(appointment_request)
    @appointment_request = appointment_request

    mail(
      to: @appointment_request.guest_email,
      subject: "Your appointment request was #{@appointment_request.status}"
    )
  end
end
