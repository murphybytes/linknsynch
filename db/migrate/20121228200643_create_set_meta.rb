class CreateSetMeta < ActiveRecord::Migration
  def change
    create_table :set_meta do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
