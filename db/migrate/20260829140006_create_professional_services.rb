class CreateProfessionalServices < ActiveRecord::Migration[8.0]
  def change
    create_table :professional_services, id: :string do |t|
      t.string :professional_id, null: false
      t.string :service_id, null: false

      t.timestamps
    end

    add_index :professional_services, [ :professional_id, :service_id ], unique: true
    add_index :professional_services, :service_id
    add_foreign_key :professional_services, :professionals
    add_foreign_key :professional_services, :services
  end
end
