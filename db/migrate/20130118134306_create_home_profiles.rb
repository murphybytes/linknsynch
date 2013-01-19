class CreateHomeProfiles < ActiveRecord::Migration
  def change
    create_table :home_profiles do |t|
      t.string :name
      t.text :description
      t.integer :home_count
      t.integer :user_id
      t.decimal :btu_required
      t.integer :base_temperature

      t.timestamps
    end
  end
end
