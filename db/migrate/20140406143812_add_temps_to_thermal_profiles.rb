class AddTempsToThermalProfiles < ActiveRecord::Migration
  def up
    add_column :thermal_storage_profiles, :base_temperature, :integer
    add_column :thermal_storage_profiles, :thermostat_temperature, :integer
    
    ThermalStorageProfile.update_all base_temperature: 60, thermostat_temperature: 70
  end

  def down
    remove_column :thermal_storage_profiles, :base_temperature
    remove_column :thermal_storage_profiles, :thermostat_temperature

  end
  
end
