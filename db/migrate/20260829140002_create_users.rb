class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :string do |t|
      ## Tenant
      t.string :tenant_id, null: false

      ## Custom attributes
      t.string :name, null: false
      t.string :role, default: "admin", null: false

      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :tenant_id
    add_foreign_key :users, :tenants
  end
end
