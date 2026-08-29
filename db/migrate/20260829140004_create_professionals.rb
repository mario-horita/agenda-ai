class CreateProfessionals < ActiveRecord::Migration[8.0]
  def change
    create_table :professionals, id: :string do |t|
      t.string :tenant_id, null: false
      t.string :name, null: false
      t.string :email
      t.string :phone
      t.text :bio
      t.string :avatar_url
      t.integer :buffer_minutes, default: 0, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :professionals, :tenant_id
    add_index :professionals, [ :tenant_id, :active ]
    add_foreign_key :professionals, :tenants
  end
end
