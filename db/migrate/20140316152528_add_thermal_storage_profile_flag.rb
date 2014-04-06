class AddThermalStorageProfileFlag < ActiveRecord::Migration
  def up
    add_column :thermal_storage_profiles, :water_heat_flag, :boolean

    ThermalStorageProfile.update_all water_heat_flag: true  

  end

  def down
    remove_column :thermal_storage_profiles, :water_heat_flag
  end
end
