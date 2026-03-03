module AppointmentRequests
  class Create
    def initialize(service:, guest_name:, guest_email:, starts_at:)
      @service = service
      @nutritionist = service.nutritionist
      @guest_name = guest_name
      @guest_email = guest_email.to_s.strip.downcase
      @starts_at = starts_at
    end

    def call
      create_one_request
    rescue ActiveRecord::RecordNotUnique
      create_one_request
    end

    private

    def create_one_request
      ApplicationRecord.transaction do
        # Reject previous pending requests
        AppointmentRequest
        .where(guest_email: @guest_email, status: :pending)
        .update_all(
          status: AppointmentRequest.statuses[:rejected],
          updated_at: Time.current
        )

        # Create a new request
        AppointmentRequest.create!(
          nutritionist: @nutritionist,
          service: @service,
          guest_name: @guest_name,
          guest_email: @guest_email,
          starts_at: @starts_at,
          ends_at: @starts_at + @service.duration_minutes.minutes,
          status: :pending
        )
      end
    end
  end
end
