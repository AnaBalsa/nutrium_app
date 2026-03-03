class AppointmentRequest < ApplicationRecord
  belongs_to :nutritionist
  belongs_to :service

  enum status: { pending: 0, accepted: 1, rejected: 2 }

  validates :guest_name, :guest_email, :starts_at, :ends_at, :status, presence: true
  validate :ends_after_starts

  private

  def ends_after_starts
    return if starts_at.blank? || ends_at.blank?
    errors.add(:ends_at, "must be after starts_at") if ends_at <= starts_at
  end
end
