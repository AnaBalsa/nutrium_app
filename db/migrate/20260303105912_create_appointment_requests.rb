class CreateAppointmentRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :appointment_requests do |t|
      t.references :nutritionist, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.string :guest_name
      t.string :guest_email
      t.datetime :starts_at
      t.datetime :ends_at
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :appointment_requests, [ :guest_email, :status ]
    add_index :appointment_requests, [ :nutritionist_id, :status, :starts_at, :ends_at ],
              name: "index_appointReq_nutri_status_time"
  end
end
