class CreateClients < ActiveRecord::Migration[8.0]
  def change
    create_table :clients, id: :string do |t|
      t.string :tenant_id, null: false
      t.string :name, null: false
      t.string :email
      t.string :phone
      t.integer :appointments_count, default: 0, null: false
      t.integer :no_show_count, default: 0, null: false
      t.datetime :last_appointment_at

      t.timestamps
    end

    add_index :clients, :tenant_id
    add_index :clients, [ :tenant_id, :email ]
    add_index :clients, [ :tenant_id, :phone ]
    add_foreign_key :clients, :tenants
  end
end
