class AppointmentRequestMailer < ApplicationMailer
  def send_notification(appointment_request)
    @appointment_request = appointment_request

    nutritionist = appointment_request.service.nutritionist
    from_email = "#{nutritionist.name.parameterize}@gmail.com"

    mail(
      to: @appointment_request.guest_email,
      from: from_email,
      subject: "Your appointment request was #{@appointment_request.status}"
    )
  end
end
