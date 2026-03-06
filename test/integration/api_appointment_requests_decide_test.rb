require "test_helper"

class ApiAppointmentRequestsDecideTest < ActionDispatch::IntegrationTest
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

  test "PATCH decide returns 200 and updates status" do
    travel_to Time.zone.parse("2026-03-05 10:00:00") do
      request = AppointmentRequests::Create.new(
        service: @service,
        guest_name: "Ana",
        guest_email: "a@gmail.com",
        starts_at: Time.zone.parse("2026-03-10 10:00:00")
      ).call

      assert request.pending?

      patch "/api/appointment_requests/#{request.id}/decide",
            params: { decision: "accepted" },
            as: :json

      assert_response :success

      body = JSON.parse(response.body)
      assert_equal request.id, body["id"]
      assert_equal "accepted", body["status"]

      request.reload
      assert request.accepted?
    end
  end

    test "GET index returns only pending appointment requests for a nutritionist" do
    travel_to Time.zone.parse("2026-03-05 10:00:00") do
      starts = Time.zone.parse("2026-03-10 10:00")

      pending_request = AppointmentRequests::Create.new(
        service: @service,
        guest_name: "Ana",
        guest_email: "a@test.com",
        starts_at: starts
      ).call

      rejected_request = AppointmentRequests::Create.new(
        service: @service,
        guest_name: "Bruno",
        guest_email: "b@test.com",
        starts_at: starts + 1.hour
      ).call

      # reject manually
      rejected_request.update!(status: :rejected)

      get "/api/nutritionists/#{@nutritionist.id}/appointment_requests",
          params: { status: "pending" },
          as: :json

      assert_response :success

      body = JSON.parse(response.body)

      assert_equal 1, body.length
      assert_equal pending_request.id, body.first["id"]
      assert_equal "pending", body.first["status"]
    end
  end
end
