require "test_helper"

class AppointmentRequestMailerTest < ActionMailer::TestCase
  setup do
    @nutritionist = Nutritionist.create!(name: "Ana Silva")
    @service = Service.create!(
      nutritionist: @nutritionist,
      name: "Initial Appointment",
      price: 50,
      currency: "EUR",
      duration_minutes: 60,
      location_name: "Braga",
      location_lat: 41.5454,
      location_lng: -8.4265
    )
  end

  test "send_notification" do
    request = AppointmentRequests::Create.new(
      service: @service,
      guest_name: "Ana",
      guest_email: "a@gmail.com",
      starts_at: Time.current + 1.day
    ).call

    mail = AppointmentRequestMailer.send_notification(request)
    assert_equal "Your appointment request was pending", mail.subject
    assert_equal [ "a@gmail.com" ], mail.to
    assert_equal [ "ana-silva@gmail.com" ], mail.from
    assert_includes mail.body.encoded, request.guest_name
  end
end
