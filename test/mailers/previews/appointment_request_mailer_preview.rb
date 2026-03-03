# Preview all emails at http://localhost:3000/rails/mailers/appointment_request_mailer
class AppointmentRequestMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/appointment_request_mailer/send_notification
  def send_notification
    AppointmentRequestMailer.send_notification
  end
end
