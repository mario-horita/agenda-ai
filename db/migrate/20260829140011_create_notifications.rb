class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications, id: :string do |t|
      t.string :appointment_id, null: false
      t.string :channel, default: "email", null: false
      t.string :notification_type, null: false
      t.string :status, default: "pending", null: false
      t.datetime :sent_at
      t.datetime :scheduled_for
      t.text :metadata

      t.timestamps
    end

    add_index :notifications, :appointment_id
    add_index :notifications, [ :status, :scheduled_for ]
    add_foreign_key :notifications, :appointments
  end
end
