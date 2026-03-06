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
      auto_rejected_ids =[]
      should_notify_decision = false

      ApplicationRecord.transaction do
        @appointment_request.lock!

        unless @appointment_request.pending?
          decided = @appointment_request
          next
        end

        @appointment_request.update!(status: @decision)
        decided = @appointment_request
        should_notify_decision = true

        if @decision == :accepted
          auto_rejected_ids = reject_overlapping_pending_requests_and_return_ids
        end
      end

      AppointmentRequestMailer.send_notification(decided).deliver_later if should_notify_decision

      if auto_rejected_ids.any?
        # send email for each auto rejected request
        AppointmentRequest.where(id: auto_rejected_ids).find_each do |notification|
          AppointmentRequestMailer.send_notification(notification).deliver_later
        end
      end

        decided
    end

    private

    # overlap: starts_at < other.ends_at AND ends_at > other.starts_at
    def reject_overlapping_pending_requests_and_return_ids
      overlapping = AppointmentRequest
                      .where(nutritionist_id: @appointment_request.nutritionist_id, status: :pending)
                      .where.not(id: @appointment_request.id)
                      .where("starts_at < ? AND ends_at > ?", @appointment_request.ends_at, @appointment_request.starts_at)

      ids = overlapping.pluck(:id)

      overlapping.update_all(
        status: AppointmentRequest.statuses[:rejected],
        updated_at: Time.current
      )

      ids
    end
  end
end
