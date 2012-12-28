class CreateSamples < ActiveRecord::Migration
  def change
    create_table :samples do |t|
      t.integer :set_meta_id
      t.datetime :sample_time
      t.integer :generated_kilowatts
      t.integer :temperature

      t.timestamps
    end
    add_index :samples, :set_meta_id
    add_index :samples, :sample_time
  end
end
