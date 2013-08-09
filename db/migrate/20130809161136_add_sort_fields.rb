class AddSortFields < ActiveRecord::Migration
  def up
    add_column :home_profiles, :priority, :integer 
    add_column :thermal_storage_profiles, :priority, :integer
    create_table :calculations do |t|
      t.string      :name
      t.string      :description
      t.integer     :user_id
      t.integer     :set_meta_id 
      t.integer     :node_id 
      
    end
 
    create_table :calculations_home_profiles, :id => false do |t|
      t.integer :calculation_id
      t.integer :home_profile_id
    end
    # manual index name because generated one is too long
    add_index :calculations_home_profiles, [:calculation_id, :home_profile_id], name: 'chp_index'
    
    create_table :calculations_thermal_storage_profiles, :id => false do |t|
      t.integer :calculation_id
      t.integer :thermal_storage_profile_id
    end

    add_index :calculations_thermal_storage_profiles, [ :calculation_id, :thermal_storage_profile_id ], name: 'ctsp_index'
  end

  def down
    remove_column :home_profiles, :priority
    remove_column :thermal_storage_profiles, :priority
    drop_table :calculations
    drop_table :calculations_home_profiles
    drop_table :calculations_thermal_storage_profiles
  end
end
