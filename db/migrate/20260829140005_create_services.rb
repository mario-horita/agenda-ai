class CreateServices < ActiveRecord::Migration[8.0]
  def change
    create_table :services, id: :string do |t|
      t.string :tenant_id, null: false
      t.string :name, null: false
      t.text :description
      t.integer :duration_minutes, null: false
      t.integer :price_cents, default: 0, null: false
      t.string :currency, default: "BRL", null: false
      t.boolean :active, default: true, null: false
      t.integer :sort_order, default: 0, null: false

      t.timestamps
    end

    add_index :services, :tenant_id
    add_index :services, [ :tenant_id, :active ]
    add_foreign_key :services, :tenants
  end
end
