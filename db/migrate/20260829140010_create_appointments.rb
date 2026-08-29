class CreateAppointments < ActiveRecord::Migration[8.0]
  def change
    create_table :appointments, id: :string do |t|
      t.string :tenant_id, null: false
      t.string :professional_id, null: false
      t.string :service_id, null: false
      t.string :client_id, null: false

      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :status, default: "confirmed", null: false
      t.integer :price_cents, default: 0, null: false

      t.string :cancellation_reason
      t.datetime :cancelled_at
      t.string :cancelled_by

      t.integer :lock_version, default: 0, null: false

      t.timestamps
    end

    add_index :appointments, [ :tenant_id, :starts_at ]
    add_index :appointments, [ :professional_id, :starts_at, :status ]
    add_index :appointments, :client_id
    add_index :appointments, [ :tenant_id, :status ]

    add_foreign_key :appointments, :tenants
    add_foreign_key :appointments, :professionals
    add_foreign_key :appointments, :services
    add_foreign_key :appointments, :clients
  end
end
