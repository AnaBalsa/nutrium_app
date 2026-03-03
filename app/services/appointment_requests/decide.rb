module AppointmentRequests
  class Decide
    ALLOWED_DECISIONS = %i[accepted rejected].freeze

    def initialize(appointment_request:, decision:)
      @appointment_request = appointment_request
      @decision = decision.to_s.downcase.to_sym
    end

    def call
      raise ArgumentError, "invalid decision" unless ALLOWED_DECISIONS.include?(@decision)

      decided = nil

      ApplicationRecord.transaction do
        @appointment_request.lock!
        raise ArgumentError, "request is not pending" unless @appointment_request.pending?

        @appointment_request.update!(status: @decision)

        reject_overlapping_pending_requests! if @decision == :accepted
        decided = @appointment_request
      end

      AppointmentRequestMailer.send_notification(decided).deliver_later
      decided
    end

    private

    # overlap: starts_at < other.ends_at AND ends_at > other.starts_at
    def reject_overlapping_pending_requests!
      AppointmentRequest
        .where(nutritionist_id: @appointment_request.nutritionist_id, status: :pending)
        .where.not(id: @appointment_request.id)
        .where("starts_at < ? AND ends_at > ?", @appointment_request.ends_at, @appointment_request.starts_at)
        .update_all(status: AppointmentRequest.statuses[:rejected], updated_at: Time.current)
    end
  end
end
