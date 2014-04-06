class AddBtuToThermalProfile < ActiveRecord::Migration
  def up
    add_column :thermal_storage_profiles, :btu_factor, :decimal
    ThermalStorageProfile.update_all btu_factor: 712.4889
  end

  def down
    remove_column :thermal_storage_profiles, :btu_factor
  end
end
