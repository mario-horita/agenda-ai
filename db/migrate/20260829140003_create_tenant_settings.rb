class CreateTenantSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :tenant_settings, id: :string do |t|
      t.string :tenant_id, null: false
      t.integer :cancellation_window_hours, default: 24, null: false
      t.boolean :allow_reschedule, default: true, null: false
      t.integer :reminder_hours, default: 24, null: false
      t.string :notification_channels, default: "email", null: false
      t.text :booking_page_config

      t.timestamps
    end

    add_index :tenant_settings, :tenant_id, unique: true
    add_foreign_key :tenant_settings, :tenants
  end
end
