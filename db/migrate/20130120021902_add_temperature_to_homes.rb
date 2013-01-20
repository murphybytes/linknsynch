class AddTemperatureToHomes < ActiveRecord::Migration
  def change
    add_column :home_profiles, :thermostat_temperature, :integer
  end
end
