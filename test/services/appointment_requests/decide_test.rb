require "test_helper"

class AppointmentRequests::DecideTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    @nutritionist = Nutritionist.create!(name: "Ana Silva")
    @service = Service.create!(
      nutritionist: @nutritionist,
      name: "Follow-up",
      price: 50,
      currency: "EUR",
      duration_minutes: 60,
      location_name: "Braga",
      location_lat: 41.5454,
      location_lng: -8.4265
    )
  end

  test "accepting a request rejects overlapping pending requests for nutritionist" do
    travel_to Time.zone.parse("2026-03-05 10:00:00") do
      starts = Time.zone.parse("2026-03-10 10:00:00")

      request1 = AppointmentRequests::Create.new(
        service: @service,
        guest_name: "Ana",
        guest_email: "a@gmail.com",
        starts_at: starts
      ).call

      request2 = AppointmentRequests::Create.new(
        service: @service,
        guest_name: "Bruno",
        guest_email: "b@gmail.com",
        starts_at: starts + 10.minutes
      ).call

      assert request1.pending?
      assert request2.pending?

      AppointmentRequests::Decide.new(
        appointment_request: request1,
        decision: :accepted
      ).call

      request1.reload
      request2.reload

      assert request1.accepted?
      assert request2.rejected?
    end
  end
end
