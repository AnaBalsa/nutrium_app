class AddUniquePendingIndexToAppointmentRequests < ActiveRecord::Migration[7.2]
  def change
    add_index :appointment_requests,
              :guest_email,
              unique: true,
              where: "status = 0",
              name: "index_unique_pending_request_per_email"
  end
end
