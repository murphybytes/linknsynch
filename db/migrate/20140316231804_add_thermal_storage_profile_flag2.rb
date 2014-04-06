class AddThermalStorageProfileFlag2 < ActiveRecord::Migration
  def up
    remove_column :thermal_storage_profiles, :water_heat_flag
    add_column :thermal_storage_profiles, :water_heat_flag, :integer
    ThermalStorageProfile.update_all water_heat_flag: 1
  end

  def down
    remove_column :thermal_storage_profiles, :water_heat_flag
    add_column :thermal_storage_profiles, :water_heat_flag, :boolean
    ThermalStorageProfile.update_all water_heat_flag: true
  end
end
