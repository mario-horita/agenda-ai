class CreateAvailabilities < ActiveRecord::Migration[8.0]
  def change
    create_table :availabilities, id: :string do |t|
      t.string :professional_id, null: false
      t.integer :day_of_week, null: false # 0=Sunday, 1=Monday, ..., 6=Saturday
      t.time :start_time, null: false
      t.time :end_time, null: false

      t.timestamps
    end

    add_index :availabilities, [ :professional_id, :day_of_week ]
    add_index :availabilities, [ :professional_id, :day_of_week, :start_time ], unique: true, name: "idx_availabilities_prof_day_start"
    add_foreign_key :availabilities, :professionals
  end
end
