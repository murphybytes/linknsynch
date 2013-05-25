class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.string :name
      t.string :node_type

      t.timestamps
    end
    add_index :nodes, :name
    add_index :nodes, :node_type
  end
end
