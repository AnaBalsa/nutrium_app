require "test_helper"

class AppointmentRequests::CreateTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

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

  test "rejects previous pending request for same guest and creates a new pending request" do
    travel_to Time.zone.parse("2026-03-05 10:00:00") do
      email = "ana@gmail.com"

      first = AppointmentRequests::Create.new(
        service: @service,
        guest_name: "Ana",
        guest_email: email,
        starts_at: Time.current + 1.day
      ).call

      assert first.pending?

      second = AppointmentRequests::Create.new(
        service: @service,
        guest_name: "Ana",
        guest_email: email,
        starts_at: Time.current + 2.days
      ).call

      assert second.pending?
      assert_not_equal first.id, second.id

      first.reload
      second.reload

      assert first.rejected?
      assert second.pending?

      assert_equal 1, AppointmentRequest.where(guest_email: email, status: :pending).count
    end
  end

  test "normalizes guest email" do
    raw_email = " ANA@Gmail.com "

    req = AppointmentRequests::Create.new(
      service: @service,
        guest_name: "Ana",
        guest_email: raw_email,
        starts_at: Time.current + 1.day
    ).call

    assert_equal "ana@gmail.com", req.guest_email
  end
end
