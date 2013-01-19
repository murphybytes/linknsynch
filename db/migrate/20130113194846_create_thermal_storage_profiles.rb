class CreateThermalStorageProfiles < ActiveRecord::Migration
  def change
    create_table :thermal_storage_profiles do |t|
      t.string :name
      t.text :description
      t.integer :units
      t.integer :user_id
      t.decimal :capacity
      t.decimal :storage
      t.decimal :charge_rate
      t.decimal :base_threshold
      t.decimal :usage

      t.timestamps
    end
  end
end
