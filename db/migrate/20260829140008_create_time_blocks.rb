class CreateTimeBlocks < ActiveRecord::Migration[8.0]
  def change
    create_table :time_blocks, id: :string do |t|
      t.string :professional_id, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.time :start_time
      t.time :end_time
      t.string :reason, null: false
      t.boolean :all_day, default: false, null: false

      t.timestamps
    end

    add_index :time_blocks, [ :professional_id, :start_date, :end_date ]
    add_foreign_key :time_blocks, :professionals
  end
end
