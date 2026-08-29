class CreateTenants < ActiveRecord::Migration[8.0]
  def change
    create_table :tenants, id: :string do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :timezone, default: "America/Sao_Paulo", null: false
      t.string :phone
      t.string :logo_url
      t.string :primary_color, default: "#6366f1"
      t.string :secondary_color, default: "#8b5cf6"
      t.string :plan, default: "starter", null: false
      t.date :trial_ends_at

      t.timestamps
    end

    add_index :tenants, :slug, unique: true
  end
end
